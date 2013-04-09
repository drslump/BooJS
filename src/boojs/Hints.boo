namespace boojs

import System.IO
import System(Console)

import Boo.Ide(CompletionProposer)
import Boo.Lang.Compiler(IO, BooCompiler, Steps, Ast)


class Commands:

    static final TERMINATOR = '|||'

    static def locals(index as ProjectIndex, line as string):
        parts = line.Split(char('@'))
        filename = parts[0]
        ln as int
        int.TryParse(parts[1], ln)

        code = File.ReadAllText(filename)
        for item in index.LocalsAt(filename, code, ln):
            print item

        print TERMINATOR

    static def members(index as ProjectIndex, line as string):
        parts = line.Split(char('@'))
        filename = parts[0]
        ofs as int
        int.TryParse(parts[1], ofs)

        code = File.ReadAllText(filename)

        left = code.Substring(0, ofs)
        right = code.Substring(ofs)

        # Obtain current type members if no dot is found
        if left[len(left) - 1] != char('.'):
            left = left + '; .'

        code = '{0}{1}; {2}' % (left, '__cursor_location__', right)

        items = index.ProposalsFor(filename, code)
        for itm in items:
            name = itm.Name

            # Overloads in BooJs are renamed to xxx$0, xxx$1 ...
            if name =~ /\$\d+$/:
                name = name.Substring(0, name.IndexOf('$'))

            print '{0}|{1}|{2}' % (name, itm.EntityType, itm.Description)

        print TERMINATOR

    static def globals(index as ProjectIndex, line as string):
        filename = line
        code = File.ReadAllText(filename)

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
                print '{0}|{1}|{2}' % (m.Name, m.Entity.EntityType, m.Entity.ToString())

            # TODO: This logic only seems to work for external references (Reflection)
            for imp in module.Imports:
                #print 'IMPORT:', imp, imp.Entity, imp.Entity.EntityType
                if imp.Alias and imp.Alias.Entity:
                    print '{0}|{1}|{2}' % (imp.Alias.Name, imp.Alias.Entity.EntityType, imp.Alias.Entity.ToString())
                    continue

                mie = imp.Expression as Ast.MethodInvocationExpression
                mre.Target.Entity = imp.Entity
                items = CompletionProposer.ForExpression(mre)
                for item in items:
                    if mie:
                        continue unless mie.Arguments.Contains({n as Ast.ReferenceExpression | n.Name == item.Name})

                    print '{0}|{1}|{2}' % (item.Name, item.EntityType, item.Description)

        print TERMINATOR

    static def overloads(index as ProjectIndex, line as string):
    """
    Unused
    """
        parts = line.Split(char(' '))
        method = parts[0]
        parts = join(parts[1:], ' ').Split(char('@'))
        filename = parts[0]
        ln as int
        int.TryParse(parts[1], ln)

        code = File.ReadAllText(filename)

        items = index.MethodsFor(filename, code, method, ln)
        for item in items:
            print item

        print TERMINATOR

    static def target(index as ProjectIndex, line as string):
        pass

    static def parse(index as ProjectIndex, line as string):
        filename = line
        code = File.ReadAllText(filename)

        #index.Parse(filename, code)
        index.WithModule(filename, code) do(module):
            pass

        for warn in index.Context.Warnings:
            print "${warn.Code}|${warn.LexicalInfo.Line}|${warn.LexicalInfo.Column}|${warn.Message}"
        for error in index.Context.Errors:
            print "${error.Code}|${error.LexicalInfo.Line}|${error.LexicalInfo.Column}|${error.Message}"

        print TERMINATOR

    static def entity(index as ProjectIndex, line as string):
        # filename@ln:col
        parts = line.Split(char('@'))
        filename = parts[0]
        parts = parts[1].Split(char(':'))
        ln as int
        int.TryParse(parts[0], ln)
        col as int
        int.TryParse(parts[1], col)

        code = File.ReadAllText(filename)

        ent = index.EntityAt(filename, code, ln, col)

        # For internal entities we have access to their node's lexical info
        if ientity = ent as Boo.Lang.Compiler.TypeSystem.IInternalEntity:
            li = ientity.Node.LexicalInfo
            print '{0}|{1}|{2}@{3}' % (ent.FullName, ent.EntityType, li.FileName, li.Line)
        # External entities do not have lexical information
        # TODO: The compiler may be made to include this info as custom attributes in debug mode?
        else:
            print '{0}|{1}' % (ent.FullName, ent.EntityType)

        print TERMINATOR




def hints(cmdline as CommandLine):

    index = (ProjectIndex.BooJs() if not cmdline.HintsBoo else ProjectIndex.Boo())
    for refe in cmdline.References:
        index.AddReference(refe)

    while true:   # Loop indefinitely
        line = gets()
        if line.ToLower() in ('q', 'quit', 'exit'):
            break

        parts = line.Split(char(' '))
        if not typeof(Commands).GetMethod(parts[0]):
            Console.Error.WriteLine('Unknown command')
            continue

        try:
            line = join(parts[1:], ' ')
            args = (index, line)
            typeof(Commands).GetMethod(parts[0]).Invoke(null, args)

        except ex as System.Reflection.TargetParameterCountException:
            Console.Error.WriteLine('Malformed command')
