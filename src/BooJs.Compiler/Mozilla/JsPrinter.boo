namespace BooJs.Compiler.Mozilla

import System.IO(TextWriter)
import System.Web.Script.Serialization(JavaScriptSerializer) from 'System.Web.Extensions'

import Boo.Lang.Compiler.Ast(Module)

import BooJs.Compiler(CompilerContext)
import BooJs.Compiler.SourceMap(MapBuilder)


class JsPrinter(Printer):
"""
    Generates Javascript source code from the Mozilla AST
"""
    [property(SourceMap)]
    _srcmap as MapBuilder = null


    def constructor(writer as TextWriter):
        super(writer)

    override def Visit(node as Node):
        return if not node

        if SourceMap and node and node.loc:
            identifier = node as Identifier
            ident = (identifier.name if identifier else null)
            pos as Position = node.loc.start
            SourceMap.Map(node.loc.source, pos.line-1, pos.column, Line, Column, ident)


        # Output provided verbatim source code (ie: for eval calls)
        if node.verbatim is not null:
            Parens Precedence.Sequence:
                lines = /\r\n|\n/.Split(node.verbatim)
                Write lines[0]
                for line in lines[1:]:
                    WriteLine
                    WriteIndented line
            return

        super(node)

    protected def WrapProgram(node as Program):
        # TODO: Move to custom step
        module = node['module'] as Module

        deps = List of IExpression() { Literal('exports'), Literal('Boo') }
        refs = List of IPattern() { Identifier('exports'), Identifier('Boo') }

        # Get namespace mapping annotations
        mapping as Hash = module['nsmapping']
        asmrefs as Hash = module['nsasmrefs']

        for ns in mapping.Keys:
            if ns in asmrefs:
                print '{0} => {1}' % (ns, mapping[ns] + ':' + asmrefs[ns])
                deps.Add( Literal(ns + ':' + asmrefs[ns]) )
            else:
                print '{0} => {1}' % (ns, mapping[ns])
                deps.Add( Literal(ns) )
            refs.Add( Identifier(mapping[ns]) )

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

        # Add source map to the runtime
        # TODO: Sourcemaps should be per assembly not module
        if SourceMap and CompilerContext.Current.Parameters.Debug:
            srcmap = SourceMap.ToDict()
            Write 'Boo.sourcemap({0});', JavaScriptSerializer().Serialize(srcmap)
            WriteLine


    virtual def OnWhileStatement(node as WhileStatement):
        WriteIndented 'while ('
        Visit node.test
        Write ') '
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

    virtual def OnSwitchStatement(node as SwitchStatement):
        WriteIndented 'switch ('
        Visit node.discriminant
        WriteLine ') {'
        for case in node.cases:
            WriteIndented 'case '
            Visit case.test
            WriteLine ':'
            Indent
            for st in case.consequent:
                WriteIndented
                Visit st
            Dedent
        WriteIndented
        WriteLine '}'

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
        l = len(node.properties)-1
        for idx as int, prop as ObjectExpressionProp in enumerate(node.properties):
            WriteIndented
            Visit prop.key
            Write ': '
            Visit prop.value
            Write ', ' if idx < l
            WriteLine
        Dedent
        WriteIndented '}'
        WriteLine

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
        WriteIndented
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
        line = Line
        WriteIndented
        Visit node.expression
        Trim
        WriteLine ';'
        # Include additional new line if the expressions spanned multiple lines
        if Line-line > 2:
            WriteLine

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
        WriteLine if len(node.declarations) > 1
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
        elif node.regexp:
            Write node.value
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


