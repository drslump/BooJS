namespace BooJs.Compiler.Mozilla

import System.IO(TextWriter)

import Boo.Lang.Compiler.Ast as BooAst


class JsPrinter(Printer):
"""
    Generates Javascript source code from the Mozilla AST
"""

    def constructor(writer as TextWriter):
        super(writer)

    protected virtual def WrapProgram(node as Program):
        # TODO: Move to custom step
        module = node['module'] as Boo.Lang.Compiler.Ast.Module

        deps = List of IExpression()
        refs = List of IPattern()
        prefixed = {}


        for imp in module.Imports:
            mie = imp.Expression as BooAst.MethodInvocationExpression
            if mie:
                for alias in mie.Arguments:
                    trycast = alias as BooAst.TryCastExpression
                    if trycast:
                        deps.Add(Literal(imp.Namespace + '.' + trycast.Target))
                        if imp.Alias:
                            refs.Add(Identifier(imp.Alias + '_' + trycast.Type))
                            prefixed[imp.Alias.Name] = prefixed[imp.Alias.Name] or []
                            (prefixed[imp.Alias.Name] as List).Add(alias.ToString())
                        else:
                            refs.Add(Identifier(trycast.Type.ToString()))
                    else:
                        deps.Add(Literal(imp.Namespace + '.' + alias))
                        if imp.Alias:
                            refs.Add(Identifier(imp.Alias + '_' + alias))
                            prefixed[imp.Alias.Name] = prefixed[imp.Alias.Name] or []
                            (prefixed[imp.Alias.Name] as List).Add(alias.ToString())
                        else:
                            refs.Add(Identifier(alias.ToString()))
            else:
                if not imp.Alias:
                    raise 'Wildcard import (' + imp.Expression + ') not supported'
                else:
                    deps.Add(Literal(imp.Namespace))
                    refs.Add(Identifier(imp.Alias.ToString()))


        # Assign aliases before any other statement
        if len(prefixed):
            decls = VariableDeclaration()
            for itm in prefixed:

                h = ObjectExpression()
                for key in itm.Value:
                    prop = ObjectExpressionProp(key, Identifier(itm.Key + '_' + key))
                    h.properties.Add(prop)

                decl = VariableDeclarator(itm.Key as string, init: h);
                decls.declarations.Add(decl)

            node.body.Insert(0, decls)


        # Use Boo.define to bootstrap the module contents
        call = CallExpression()
        call.callee = MemberExpression(
            object: Identifier(name: 'Boo'),
            property: Identifier(name: 'define')
        )
        call.arguments.Add(Literal(value: (module.Namespace.ToString() if module.Namespace else '')))
        call.arguments.Add(ArrayExpression(elements: deps))
        fn = FunctionExpression(params: refs, body: BlockStatement(body: node.body))
        call.arguments.Add(fn)

        return ExpressionStatement(call)

    virtual def OnProgram(node as Program):
        Visit WrapProgram(node)

    virtual def OnWhileStatement(node as WhileStatement):
        WriteIndented 'while ('
        Visit node.test
        Write ')'
        Visit node.body

    virtual def OnDoWhileStatement(node as DoWhileStatement):
        WriteIndented 'do '
        Visit node.body
        WriteIndented ' while ('
        Visit node.test
        Write ')'

    virtual def OnForStatement(node as ForStatement):
        WriteIndented 'for ('
        Visit node.init
        Write '; '
        Visit node.test
        Write '; '
        Visit node.update
        Write ') '
        Visit node.body

    virtual def OnThisExpression(node as ThisExpression):
        Write 'this'

    virtual def OnArrayExpression(node as ArrayExpression):
        Write '['
        WriteCommaSeparatedList node.elements
        Write ']'

    virtual def OnSequenceExpression(node as SequenceExpression):
        Write '('
        WriteCommaSeparatedList node.expressions
        Write ')'

    virtual def OnObjectExpression(node as ObjectExpression):
        if not len(node.properties):
            Write '{}'
            return

        WriteLine '{'
        Indent
        for prop in node.properties:
            WriteIndented
            Visit prop.key
            Write ': '
            Visit prop.value
            WriteLine ', '
        Dedent
        WriteLine '}'

    virtual def OnFunctionExpression(node as FunctionExpression):
        Write 'function '
        Visit node.id
        Write '('
        WriteCommaSeparatedList node.params
        Write ') '
        Visit node.body
        Trim

    virtual def OnBlockStatement(node as BlockStatement):
        PrecedenceStack.Add(Precedence.None)
        WriteLine '{'
        Indent
        Visit(node.body)
        Trim
        WriteLine
        Dedent
        WriteIndented '}'
        WriteLine
        PrecedenceStack.Pop()

    virtual def OnFunctionDeclaration(node as FunctionDeclaration):
        WriteIndented 'function '
        Visit node.id
        Write ' ('
        WriteCommaSeparatedList node.params
        Write ') '
        Visit node.body
        WriteLine

    virtual def OnReturnStatement(node as ReturnStatement):
        WriteIndented 'return '
        Visit node.argument
        WriteLine ';'

    virtual def OnSwitchStatement(node as SwitchStatement):
        Visit node.discriminant
        Visit node.cases

    virtual def OnWithStatement(node as WithStatement):
        WriteIndented 'with ('
        Visit node.object
        Write ') '
        Visit node.body

    virtual def OnContinueStatement(node as ContinueStatement):
        WriteIndented 'continue '
        Visit node.label
        WriteLine ';'

    virtual def OnBreakStatement(node as BreakStatement):
        WriteIndented 'break '
        Visit node.label
        WriteLine ';'

    virtual def OnLabeledStatement(node as LabeledStatement):
        Visit node.label
        Write ': '
        Visit node.body

    virtual def OnIfStatement(node as IfStatement):
        WriteIndented 'if ('
        Visit node.test
        Write ') '
        Visit node.consequent
        if node.alternate:
            Trim
            Write ' else '
            Visit node.alternate
        WriteLine

    virtual def OnExpressionStatement(node as ExpressionStatement):
        WriteIndented
        Visit node.expression
        Trim
        WriteLine ';'

    virtual def OnVariableDeclaration(node as VariableDeclaration):
        WriteIndented '{0} ', node.kind
        Indent
        for idx as int, decl as VariableDeclarator in enumerate(node.declarations):
            if idx > 0:
                WriteLine ','
                WriteIndented

            Visit decl.id
            if decl.init:
                Write ' = '
                Visit decl.init

            Trim

        WriteLine ';'
        Dedent

    virtual def OnUnaryExpression(node as UnaryExpression):
        precedence = (Precedence.Unary if node.prefix else Precedence.Postfix)
        Parens precedence:
            if node.prefix:
                Write node.operator
                Write ' ' if node.operator == 'typeof'
            Visit node.argument
            if not node.prefix:
                Write node.operator

    virtual def OnUpdateExpression(node as UpdateExpression):
        OnUnaryExpression(node as UnaryExpression)

    virtual def OnBinaryExpression(node as BinaryExpression):
        Parens _binaryPrecedence[node.operator]:
            Visit node.left
            Write ' {0} ', node.operator
            Visit node.right

    virtual def OnAssignmentExpression(node as AssignmentExpression):
        OnBinaryExpression(node as BinaryExpression)

    virtual def OnLogicalExpression(node as LogicalExpression):
        OnBinaryExpression(node as BinaryExpression)

    virtual def OnConditionalExpression(node as ConditionalExpression):
        Parens Precedence.Conditional:
            Visit node.test
            Write ' ? '
            Visit node.consequent
            Write ' : '
            Visit node.alternate

    virtual def OnMemberExpression(node as MemberExpression):
        Parens Precedence.Member:
            Visit node.object
        if node.computed:
            Write '['
            Visit node.property
            Write ']'
        else:
            Write '.'
            Visit node.property

    virtual def OnCallExpression(node as CallExpression):
        Parens Precedence.Call:
            # Make sure self-callable functions are defined as expressions
            if node.callee isa FunctionExpression:
                Write '('
                Visit node.callee
                Write ')'
            else:
                Visit node.callee
            Write '('
            WriteCommaSeparatedList(node.arguments)
            Write ')'

    virtual def OnNewExpression(node as NewExpression):
        Parens Precedence.New:
            Write 'new '
            Visit node._constructor
            if len(node.arguments):
                Write '('
                WriteCommaSeparatedList(node.arguments)
                Write ')'

    virtual def OnThrowStatement(node as ThrowStatement):
        WriteIndented 'throw '
        Visit node.argument
        WriteLine ';'

    virtual def OnTryStatement(node as TryStatement):
        WriteIndented 'try '
        Visit node.block
        Trim
        Visit node.handlers
        Trim
        if node.finalizer:
            Write ' finally '
            Visit node.finalizer
        WriteLine

    virtual def OnCatchClause(node as CatchClause):
        Write ' catch ('
        Visit node.param
        Write ') '
        Visit node.body

    virtual def OnLiteral(node as Literal):
        if node.value is null:
            Write 'null'
        elif node.value == true or node.value == false:
            Write node.value.ToString().ToLower()
        elif node.value isa string:
            quotes = 0
            result = ''
            for ch in (node.value as string):
                if ch == char('\''):
                    quotes++
                    result += ch
                elif ch == char('"'):
                    quotes--
                    result += ch
                elif ch == char('\n'): result += '\\n'
                elif ch == char('\r'): result += '\\r'
                elif ch == char('\u2028'): result += '\\u2028'
                elif ch == char('\u2029'): result += '\\u2029'
                else: result += ch

            quote = ('\'' if quotes <= 0 else '"')
            Write quote + result.Replace(quote, '\\' + quote) + quote
        else:
            # TODO: Properly write numbers
            Write node.value.ToString()

    virtual def OnIdentifier(node as Identifier):
        Write node.name

    virtual def OnXCodeExpression(node as XCodeExpression):
        Parens Precedence.Assignment:
            lines = /\r\n|\n/.Split(node.code)
            Write lines[0]
            for line in lines[1:]:
                WriteLine
                WriteIndented line

