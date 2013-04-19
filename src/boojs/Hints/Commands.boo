namespace boojs.Hints

import Boo.Lang.Compiler(Ast)
import Boo.Lang.Compiler.TypeSystem
import Boo.Lang.PatternMatching

import Boo.Lang.Environments(my)

import Mono(Cecil)


class Commands:

    static def parse(index as ProjectIndex, query as QueryMessage):
    """ Parse the given code reporting back any errors and warnings issued by
        the compiler.
        If extra information is requested the parse is performed with a type
        resolving compiler pipeline which will detect more errors than invalid
        syntax.
    """
        msg = ParseMessage()

        fn = index.WithCompiler
        if query.extra:
            fn = index.WithParser

        fn(query.fname, query.code) do (module):
            for warn in index.Context.Warnings:
                msg.warning(warn.Code, warn.Message, warn.LexicalInfo.Line, warn.LexicalInfo.Column)
            for error in index.Context.Errors:
                msg.error(error.Code, error.Message, error.LexicalInfo.Line, error.LexicalInfo.Column)

        return msg

    static def outline(index as ProjectIndex, query as QueryMessage):
    """ Obtain an outline tree for the source code
    """
        root = NodeMessage()
        index.WithParser(query.fname, query.code) do (module):
            module.Accept(OutlineVisitor(root))

        return root

    static def entity(index as ProjectIndex, query as QueryMessage):
    """ Get information about a given entity based on the line and column of its
        first letter.
        If an additional param with true is given then we query based on the entity
        full name, in order to obtain all possible candidates.
    """
        msg = HintsMessage()

        index.WithCompiler(query.fname, query.code) do (module):
            ent = LocationFinder(query.line, query.column).FindIn(module)
            if ent:
                if query.params and len(query.params) and query.params[0]:
                    # It seems like Boo only provides ambiguous information for internal
                    # entities. Here we resolve again based on the entity full name to get
                    # all possible candidates.
                    nrs = my(Boo.Lang.Compiler.TypeSystem.Services.NameResolutionService)
                    all = nrs.ResolveQualifiedName(ent.FullName)
                    if all:
                        ProcessEntity(index, msg, all, query.extra)
                        return

                ProcessEntity(index, msg, ent, query.extra)

        return msg

    static def locals(index as ProjectIndex, query as QueryMessage):
    """ Obtain hints for local symbols available in a method. This includes
        parameter definitions, method variables, closure variables and loop
        variables.
    """
        msg = HintsMessage()
        index.WithCompiler(query.fname, query.code) do (module):
            for entity in LocalAccumulator(query.fname, query.line).FindIn(module):
                ProcessEntity(index, msg, entity, query.extra)

        return msg

    static def members(index as ProjectIndex, query as QueryMessage):
    """ Obtain hints for completing a member reference expression. If the
        reported offset is not just after a dot it will query all symbols
        available at that point, this includes local symbols and members of
        the enclosing type.
    """

        ofs = query.offset
        left = query.code.Substring(0, ofs)
        right = query.code.Substring(ofs)

        # Add a dot (for OmittedExpression) if no dot is found
        do_locals = false
        if char('.') != left[ofs-1]:
            do_locals = true
            left += '.'

        # Parse a chunk of code backwards from the offset to detect open parens.
        # This allows to fix invalid syntax before feeding the code to the compiler,
        # this method will usually be used for autocompletion so if we are in the
        # middle of writing params to a function the syntax will not be valid at
        # that point.
        pairs = { '(': ')', '{': '}', '[': ']', ')': '(', '}': '{', ']': '[' }
        stack = []
        cnt = 0
        while cnt++ < (len(stack)+1) * 50 and ofs - cnt >= 0:
            s = left[ofs-cnt].ToString()
            continue if s not in pairs
            # Remove balanced parens or add a new one to the stack
            if len(stack) and stack[-1] == pairs[s]:
                stack.Pop()
            else:
                stack.Add(s)

        # Close any found open parens just after the offset
        code = '{0}__cursor_location__ {1} ; # {2}' % (
            left,
            join([pairs[x] for x in stack], '') + ' ; # ',
            right
        )

        for ln in code.Split(char('\n')):
            if ' ; # ' in ln:
                print '#', ln

        # Find member proposals for the cursor location
        msg = HintsMessage()
        index.WithCompiler(query.fname, code) do (module):
            node as Ast.Node = CursorLocationFinder('__cursor_location__').FindIn(module)
            if node:
                # Obtain member proposals
                for ent in CompletionProposer.ForExpression(node):
                    ProcessEntity(index, msg, ent, query.extra)

                if do_locals:
                    # Use cursor expression line if one wasn't explicitly given
                    query.line = query.line or node.LexicalInfo.Line

                    # Optimize by finding the top most block and only parse it
                    while node.ParentNode.NodeType not in (Ast.NodeType.Module, Ast.NodeType.ClassDefinition):
                        node = node.ParentNode

                    # Undo the optimization if the line is not inside its scope to work
                    # around closures being transformed by the compiler
                    if query.line < node.LexicalInfo.Line or query.line > node.EndSourceLocation.Line:
                        node = module

                    accum = LocalAccumulator(query.fname, query.line)
                    for ent in accum.FindIn(node):
                        ProcessEntity(index, msg, ent, query.extra)


        return msg

    static def globals(index as ProjectIndex, query as QueryMessage):
        msg = HintsMessage()
        index.WithCompiler(query.fname, query.code) do (module):
            # Collect current module members
            for m in module.Members:
                # Globals are wrapped inside a Module class
                if m.Name[-6:] == 'Module':
                    for mm in (m as Boo.Lang.Compiler.Ast.TypeDefinition).Members:
                        continue unless mm.IsStatic
                        continue if mm.IsInternal
                        continue if mm.Name == 'Main'
                        ProcessEntity(index, msg, mm.Entity, query.extra)
                    continue

                ProcessEntity(index, msg, m.Entity, query.extra)

            # Process imported symbols
            mre = Ast.MemberReferenceExpression()
            mre.Target = Ast.ReferenceExpression()
            for imp in module.Imports:
                # Handle aliases imports
                if imp.Alias and imp.Alias.Entity:
                    # TODO: Do we actually need to pass imp.Alias.Name ???
                    ProcessEntity(index, msg, imp.Alias.Entity, imp.Alias.Name, query.extra)
                    continue

                # Namespace imports. We fake a member reference expression for the namespace
                mre.Target.Entity = imp.Entity
                mie = imp.Expression as Ast.MethodInvocationExpression

                entities = CompletionProposer.ForExpression(mre)
                for ent in entities:
                    # Filter out namespace members not actually imported
                    continue if mie and not mie.Arguments.Contains({n as Ast.ReferenceExpression | n.Name == ent.Name})
                    ProcessEntity(index, msg, ent, query.extra)

        return msg

    static def LocationForToken(index as ProjectIndex, entity as IEntity):
    """ Find location information for the given entity.
        Returns null if we couldn't find any information or a tuple
        with the filename, the line and the column.
    """
        def find_seq(m as Cecil.MethodDefinition):
            return unless m.HasBody
            seq = m.Body.Instructions[0].SequencePoint
            return unless seq and seq.Document
            # Target the previous line
            return '{0}:{1}:{2}' % (
                seq.Document.Url,
                seq.StartLine - 1,
                seq.StartColumn + 1)

        # Internal entities provide their lexical information in their node
        if ie = entity as IInternalEntity:
            return '{0}:{1}:{2}' % (
                ie.Node.LexicalInfo.FileName,
                ie.Node.LexicalInfo.Line,
                ie.Node.LexicalInfo.Column)

        ee = entity as IExternalEntity
        if not ee:
            print '# Unable to get location info for:', entity, entity.EntityType
            return null

        # Get the metadata token from the entity
        token = Cecil.MetadataToken(ee.MemberInfo.MetadataToken)

        # Lookup the token in each module
        for asmdef in index.AssemblyDefinitions:
            for mod in asmdef.Modules:
                match definition=mod.LookupToken(token):
                    case null:
                        continue
                    case method=Cecil.MethodDefinition():
                        continue unless method.Name == entity.Name
                        return find_seq(method)
                    case prop=Cecil.PropertyDefinition():
                        continue unless prop.Name == entity.Name
                        return find_seq(prop.GetMethod)
                    # TODO: Support types and field
                    otherwise:
                        print '# DEF', definition

        return null

    static def ProcessEntity(index as ProjectIndex, msg as HintsMessage, entity as IEntity):
    """ hello world! """
        ProcessEntity(index, msg, entity, false)

    static def ProcessEntity(index as ProjectIndex, msg as HintsMessage, entity as IEntity, extra as bool):
    """ en un pais de la mancha """
        ProcessEntity(index, msg, entity, entity.Name, extra)

    static def ProcessEntity(index as ProjectIndex, msg as HintsMessage, entity as IEntity, name as string, extra as bool):
    """ lorem ipsum dolor sit """
        # Unroll ambiguous entities
        if entity.EntityType == EntityType.Ambiguous:
            for ent in (entity as Ambiguous).Entities:
                ProcessEntity(index, msg, ent, name, extra)
            return

        # Ignore compiler generated variables
        return if name.StartsWith('$')

        # Overloads in BooJs are renamed to xxx$0, xxx$1 ...
        if name =~ /\$\d+$/:
            name = name.Substring(0, name.IndexOf('$'))

        hint = HintsMessage.Hint()
        hint.node = entity.EntityType.ToString()
        hint.full = entity.FullName
        hint.name = name

        if extra:
            hint.doc = docStringFor(entity)
            hint.loc = LocationForToken(index, entity)

        match entity:
            case t=IType():
                # TODO: for extra include inherited types in params
                info = []
                info.Add('Array') if t.IsArray
                info.Add('Interface') if t.IsInterface
                info.Add('Enum') if t.IsEnum
                info.Add('Value') if t.IsValueType
                if t.IsClass:
                    info.Add('Class')
                    info.Add('Abstract') if t.IsAbstract
                    info.Add('Final') if t.IsFinal

                hint.info = join(info, ',')

            case ns=INamespace(EntityType: EntityType.Namespace):
                pass
            case p=IProperty():
                hint.type = p.Type.ToString()
            case f=IField():
                hint.type = f.Type.ToString()
            case e=IEvent():
                hint.type = e.Type.ToString()
            case lc=ILocalEntity():
                hint.type = lc.Type.ToString()
            case em=ExternalMethod():
                hint.type = em.ReturnType.ToString()
                if extra:
                    hint.params = List[of string]()
                    try:
                        for em_p in em.GetParameters():
                            hint.params.Add(em_p.Name + ': ' + em_p.Type)
                    except ex:
                        System.Console.Error.WriteLine('#' + ex.ToString().Replace('\n', '\n#'))
            case ie=IInternalEntity():
                if im = ie.Node as Ast.Method:
                    hint.type = im.ReturnType.ToString()
                    if extra:
                        hint.params = List[of string]()
                        try:
                            for im_p in im.Parameters:
                                hint.params.Add(im_p.Name + ': ' + im_p.Type)
                        except ex:
                            System.Console.Error.WriteLine('#' + ex.ToString().Replace('\n', '\n#'))
                else:
                    print '# internal', entity, entity.EntityType
                    hint.info = entity.ToString()
            otherwise:
                print '# otherwise', entity, entity.EntityType
                hint.info = entity.ToString()

        msg.hints.Add(hint)
