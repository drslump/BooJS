namespace boojs.Hints

import Boo.Lang.Compiler(Ast)
import Boo.Lang.Compiler.TypeSystem
import Boo.Lang.PatternMatching


class Commands:

    static def parse(index as ProjectIndex, query as QueryMessage):
        msg = ParseMessage()

        fn = index.WithParser
        if query.params and len(query.params) and query.params[0]:
            fn = index.WithCompiler

        fn(query.fname, query.code) do (module):
            for warn in index.Context.Warnings:
                msg.warning(warn.Code, warn.Message, warn.LexicalInfo.Line, warn.LexicalInfo.Column)
            for error in index.Context.Errors:
                msg.error(error.Code, error.Message, error.LexicalInfo.Line, error.LexicalInfo.Column)

        return msg

    static def entity(index as ProjectIndex, query as QueryMessage):
        msg = HintsMessage()
        index.WithCompiler(query.fname, query.code) do (module):
            ent = LocationFinder(query.line, query.column).FindIn(module)
            ProcessEntity(msg, ent) if ent

        /*
        # For internal entities we have access to their node's lexical info
        if ientity = ent as Boo.Lang.Compiler.TypeSystem.IInternalEntity:
            ProcessEntity(msg, ent)
        # External entities do not have lexical information
        # TODO: Use Cecil to load symbols pdb/mdb and query the assemblies by FullName
        else:
            ProcessEntity(msg, ent)
        */

        return msg

    static def outline(index as ProjectIndex, query as QueryMessage):
    """ Obtain an outline tree for the source code """
        root = NodeMessage()
        index.WithParser(query.fname, query.code) do (module):
            module.Accept(OutlineVisitor(root))

        return root

    static def locals(index as ProjectIndex, query as QueryMessage):
        msg = HintsMessage()
        index.WithCompiler(query.fname, query.code) do (module):
            for entity in LocalAccumulator(query.fname, query.line).FindIn(module):
                ProcessEntity(msg, entity)

        return msg

    static def members(index as ProjectIndex, query as QueryMessage):
        ofs = query.offset
        left = query.code.Substring(0, ofs)
        right = query.code.Substring(ofs)

        # Add a dot (for OmittedExpression) if no dot is found
        do_locals = false
        if char('.') != left[ofs-1]:
            do_locals = true
            left += '.'

        pairs = {
            '(': ')', '{': '}', '[': ']',
            ')': '(', '}': '{', ']': '['
        }

        # Parse the code backwards from the offset to detect open parens
        # Note: We just go back at most 1000 chars, should cover most cases
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
        if len(stack):
            code = '{0}__cursor_location__ {1} ; # {2}' % (
                left,
                join([pairs[x] for x in stack], '') + ' ; # ',
                right
            )
        else:
            code = '{0}__cursor_location__ ; # {1}' % (left, right)

        # for ln in code.Split(char('\n')):
        #     System.Console.Error.WriteLine('# ' + ln)

        # Find member proposals for the cursor location
        msg = HintsMessage()
        index.WithCompiler(query.fname, code) do (module):
            node as Ast.Node = CursorLocationFinder().FindIn(module)
            if node:
                # Obtain member proposals
                for ent in CompletionProposer.ForExpression(node):
                    ProcessEntity(msg, ent)

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
                        ProcessEntity(msg, ent)

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
                        ProcessEntity(msg, mm.Entity)
                    continue

                ProcessEntity(msg, m.Entity)

            # Process imported symbols
            mre = Ast.MemberReferenceExpression()
            mre.Target = Ast.ReferenceExpression()
            for imp in module.Imports:
                # Handle aliases imports
                if imp.Alias and imp.Alias.Entity:
                    ProcessEntity(msg, imp.Alias.Entity, imp.Alias.Name)
                    continue

                # Namespace imports. We fake a member reference expression for the namespace
                mre.Target.Entity = imp.Entity
                mie = imp.Expression as Ast.MethodInvocationExpression

                entities = CompletionProposer.ForExpression(mre)
                for ent in entities:
                    # Filter out namespace members not actually imported
                    continue if mie and not mie.Arguments.Contains({n as Ast.ReferenceExpression | n.Name == ent.Name})
                    ProcessEntity(msg, ent)

        return msg

    static def ProcessEntity(msg as HintsMessage, entity as IEntity):
        ProcessEntity(msg, entity, entity.Name)

    static def ProcessEntity(msg as HintsMessage, entity as IEntity, name as string):
        if entity.EntityType == EntityType.Ambiguous:
            for ent in (entity as Ambiguous).Entities:
                ProcessEntity(msg, ent, name)
            return

        # Ignore compiler generated variables
        return if name.StartsWith('$')

        # Overloads in BooJs are renamed to xxx$0, xxx$1 ...
        if name =~ /\$\d+$/:
            name = name.Substring(0, name.IndexOf('$'))

        hint = HintsMessage.Hint()
        hint.name = name
        hint.node = entity.EntityType.ToString()
        hint.doc = docStringFor(entity)

        # Lexical info is cheap to obtain for internal entities
        if ientity = entity as IInternalEntity:
            hint.file = ientity.Node.LexicalInfo.FileName
            hint.line = ientity.Node.LexicalInfo.Line
            hint.column = ientity.Node.LexicalInfo.Column

        match entity:
            case t=IType():
                info = []
                info.Add('Array') if t.IsArray
                info.Add('Interface') if t.IsInterface
                info.Add('Enum') if t.IsEnum
                info.Add('Value') if t.IsValueType
                if t.IsClass:
                    info.Add('Class')
                    info.Add('Abstract') if t.IsAbstract
                    info.Add('Final') if t.IsFinal

                hint.type = t.FullName
                hint.info = join(info, ',')
            case ns=INamespace(EntityType: EntityType.Namespace):
                hint.type = ns.FullName
            case p=IProperty():
                hint.type = p.FullName
                hint.info = p.Type.ToString()
            case f=IField():
                hint.type = f.FullName
                hint.info = f.Type.ToString()
            case e=IEvent():
                hint.type = e.FullName
                hint.info = e.Type.ToString()
            case em=ExternalMethod():
                hint.type = em.FullName
                params = []
                try:
                    for p in em.GetParameters():
                        params.Add(p.Name + ': ' + p.Type)
                except:
                    pass
                hint.info = '(' + join(params, ', ') + '): ' + em.ReturnType
            case lc=ILocalEntity():
                hint.type = lc.FullName
                hint.info = lc.Type.ToString()
            case ie=IInternalEntity():
                hint.type = ie.FullName
                match ie.Node:
                    case im=Ast.Method():
                        params = [] #[p.Name + ': ' + p.Type for p in im.Parameters]
                        hint.info = '(' + join(params, ', ') + '): ' + im.ReturnType
                    otherwise:
                        hint.info = '' + ie

            otherwise:
                print '# otherwise', entity, entity.EntityType

        msg.hints.Add(hint)

