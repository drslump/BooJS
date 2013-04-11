namespace boojs

import System.IO
import System(Console)

import Boo.Ide(CompletionProposer)
import Boo.Lang.Compiler(IO, BooCompiler, Steps, Ast)

import fastJSON(JSON, JSONParameters)


class QueryMessage:
    public command as string
    public fname as string
    public offset as int
    public line as int
    public column as int
    public params as (object)
    public nulls as bool  # If true includes null values in the response


class HintsMessage:
    struct Hint:
        type as string
        name as string
        desc as string
        sign as string

    public hints as List[of Hint]

    def constructor():
        hints = List[of Hint]()

    def hint(type, name, sign, desc):
        h = Hint(type: type, name: name, sign: sign, desc: desc)
        hints.Add(h)


class SymbolsMessage:
    struct Symbol:
        type as string
        name as string
        fname as string
        line as string
        column as string

    public symbols as List[of Symbol]

    def constructor():
        symbols = List[of Symbol]()

    def symbol(type, name, fname, line, column):
        s = Symbol(type: type, name: name, fname: fname, line: line, column: column)
        symbols.Add(s)


class ParseMessage:
    struct Error:
        code as string
        message as string
        line as int
        column as int

    public errors as List[of Error]
    public warnings as List[of Error]

    def constructor():
        errors = List[of Error]()
        warnings = List[of Error]()

    def error(code as string, message as string, line as int, column as int):
        st = Error(code: code, message: message, line: line, column: column)
        errors.Add(st)

    def warning(code as string, message as string, line as int, column as int):
        st = Error(code: code, message: message, line: line, column: column)
        warnings.Add(st)


class NodeMessage:
""" Used for generating the outline """
    public type as string
    public name as string
    public desc as string
    public visibility as string
    public line as int
    public length as int
    public members as List[of NodeMessage]

    def constructor():
        members = List[of NodeMessage]()


class OutlineVisitor(Ast.DepthFirstVisitor):
    _stack as List[of NodeMessage]

    def constructor(root as NodeMessage):
        _stack = List[of NodeMessage]()
        _stack.Add(root)

    override def OnModule(node as Ast.Module):
        root = _stack[-1]
        root.type = node.NodeType.ToString()
        root.name = node.Name

        VisitCollection(node.Members)
        Visit(node.Globals)

    override def OnClassDefinition(node as Ast.ClassDefinition):
        msg = Describe(node)
        msg.name = node.Name
        _stack.Add(msg)
        VisitCollection(node.Members)
        _stack.PopRange(len(_stack)-1)
        _stack[-1].members.Add(msg)

    override def OnMethod(node as Ast.Method):
        msg = Describe(node)
        msg.name = node.Name
        _stack[-1].members.Add(msg)

    protected def Describe(node as Ast.Node):
        msg = NodeMessage()
        msg.type = node.NodeType.ToString()
        if node.LexicalInfo:
            msg.line = node.LexicalInfo.Line
        return msg


class Commands:

    static def outline(index as ProjectIndex, query as QueryMessage):
        filename = query.fname
        code = File.ReadAllText(filename)

        # TODO: Use only the parser pipeline?
        root = NodeMessage()
        index.WithModule(filename, code) do(module):
            module.Accept(OutlineVisitor(root))

        return root

    static def locals(index as ProjectIndex, query as QueryMessage):
        filename = query.fname
        ln = query.line

        msg = HintsMessage()

        code = File.ReadAllText(filename)
        for item in index.LocalsAt(filename, code, ln):
            msg.hint('?', item, item, null)

        return msg

    static def members(index as ProjectIndex, query as QueryMessage):
        filename = query.fname
        ofs = query.offset

        code = File.ReadAllText(filename)

        left = code.Substring(0, ofs)
        right = code.Substring(ofs)

        # Obtain current type members if no dot is found
        if left[len(left) - 1] != char('.'):
            left = left + '; .'

        code = '{0}{1}; {2}' % (left, '__cursor_location__', right)

        msg = HintsMessage()
        items = index.ProposalsFor(filename, code)
        for itm in items:
            name = itm.Name

            # Overloads in BooJs are renamed to xxx$0, xxx$1 ...
            if name =~ /\$\d+$/:
                name = name.Substring(0, name.IndexOf('$'))

            msg.hint('?', name, itm.EntityType, itm.Description)

        return msg

    static def globals(index as ProjectIndex, query as QueryMessage):
        filename = query.fname
        code = File.ReadAllText(filename)

        msg = HintsMessage()
        index.WithModule(filename, code) do(module):

            mre = Ast.MemberReferenceExpression()
            mre.Target = Ast.ReferenceExpression()

            /*
            # TODO: This logic does not check for different namespaces or imports!
            mods = array(result.CompileUnit.Modules)
            for mod in mods[:-1]:
                for m in mod.Members:
                    if typent = m.Entity as Boo.Lang.Compiler.TypeSystem.IType and m.Name[-6:] == 'Module':
                        for mm in typent.GetMembers():
                            continue if mm isa Boo.Lang.Compiler.TypeSystem.IConstructor
                            continue if mm.Name == 'Main'
                            print '{0}|{1}|{2}' % (mm.Name, mm.EntityType, mm.ToString())
                    else:
                        print '{0}|{1}|{2}' % (m.Name, m.Entity.EntityType, m.Entity.ToString())
            */

            # Collect current module members
            for m in module.Members:
                continue if m.Name[-6:] == 'Module'
                msg.hint(m.Entity.EntityType.ToString(), m.Name, m.Entity.ToString(), null)

            # TODO: This logic only seems to work for external references (Reflection)
            for imp in module.Imports:
                #print 'IMPORT:', imp, imp.Entity, imp.Entity.EntityType
                if imp.Alias and imp.Alias.Entity:
                    msg.hint(imp.Alias.Entity.EntityType.ToString(), imp.Alias.Name, imp.Alias.Entity.ToString(), null)
                    continue

                mie = imp.Expression as Ast.MethodInvocationExpression
                mre.Target.Entity = imp.Entity
                items = CompletionProposer.ForExpression(mre)
                for item in items:
                    if mie:
                        continue unless mie.Arguments.Contains({n as Ast.ReferenceExpression | n.Name == item.Name})

                    msg.hint(item.EntityType.ToString(), item.Name, item.Description, null)

        return msg

    /*
    static def overloads(index as ProjectIndex, query as QueryMessage):
    """
    Unused
    """
        filename = query.filename
        method = query.param
        ln = query.line
        int.TryParse(parts[1], ln)

        code = File.ReadAllText(filename)

        items = index.MethodsFor(filename, code, method, ln)
        for item in items:
            print item
    */

    static def target(index as ProjectIndex, query as QueryMessage):
        pass

    static def parse(index as ProjectIndex, query as QueryMessage):
        filename = query.fname
        code = File.ReadAllText(filename)

        #index.Parse(filename, code)
        index.WithModule(filename, code) do(module):
            pass

        msg = ParseMessage()
        for warn in index.Context.Warnings:
            msg.warning(warn.Code, warn.Message, warn.LexicalInfo.Line, warn.LexicalInfo.Column)
        for error in index.Context.Errors:
            msg.error(error.Code, error.Message, error.LexicalInfo.Line, error.LexicalInfo.Column)

        return msg

    static def entity(index as ProjectIndex, query as QueryMessage):
        filename = query.fname
        ln = query.line
        col = query.column

        code = File.ReadAllText(filename)

        ent = index.EntityAt(filename, code, ln, col)

        symbols = SymbolsMessage()

        # For internal entities we have access to their node's lexical info
        if ientity = ent as Boo.Lang.Compiler.TypeSystem.IInternalEntity:
            li = ientity.Node.LexicalInfo
            symbols.symbol(ent.EntityType, ent.FullName, li.FileName, li.Line, -1)
        # External entities do not have lexical information
        # TODO: Use Cecil to load symbols pdb/mdb and query the assemblies by FullName
        else:
            symbols.symbol(ent.EntityType, ent.FullName, null, -1, -1)

        return symbols



def hints(cmdline as CommandLine):

    index = (ProjectIndex.BooJs() if not cmdline.HintsBoo else ProjectIndex.Boo())
    for refe in cmdline.References:
        index.AddReference(refe)

    json_params = JSONParameters()
    json_params.UseExtensions = false

    while true:   # Loop indefinitely
        line = gets()
        if line.ToLower() in ('q', 'quit', 'exit'):
            break

        try:
            query = JSON.Instance.ToObject[of QueryMessage](line)
        except ex:
            Console.Error.WriteLine('Malformed command')
            continue

        method = typeof(Commands).GetMethod(query.command)
        if not method:
            Console.Error.WriteLine('Unknown command')
            continue

        try:
            result = method.Invoke(null, (index, query))
            json_params.SerializeNullValues = query.nulls == true
            print JSON.Instance.ToJSON(result, json_params)
        except ex:
            Console.Error.WriteLine('Error: ' + ex)
