namespace BooJs.Compiler.Steps

import Boo.Lang.Compiler.Steps
import Boo.Lang.Compiler.Ast
import Boo.Lang.Compiler

import BooJs.Compiler.SourceMap


class BooJsPrinterVisitor(Visitors.TextEmitter):

    _context as CompilerContext
    
    srcmap as MapBuilder

    def constructor(writer as System.IO.TextWriter):
        super(writer)
        IndentText = '  '
        
        srcmap = MapBuilder()

    def Initialize(context as CompilerContext):
        _context = context

    def Print(ast as CompileUnit):
        OnCompileUnit(ast)
        
        #WriteLine '//@ sourceMappingURL=map.js.map'
        #print 'var map = ' + srcmap.ToString()

    protected def NotImplemented(node as Node, msg as string):
        raise CompilerErrorFactory.NotImplemented(node, msg)

    def WriteLine():
        srcmap.NewLine()
        super()
        
    def Write(str as string):
        srcmap.Column += str.Length
        super(str)

    def Map(node as Node):
    """ Maps the given node lexical info to the current position in the generated file
    """
        srcmap.Segment(node)

    def OnBoolLiteralExpression(node as BoolLiteralExpression):
        Write( ('true' if node.Value else 'false') )

    def OnNullLiteralExpression(node as NullLiteralExpression):
        Write 'null'

    def OnModule(node as Module):

        # HACK: ProcessMethodBodies step is too complex so we opt for reversing some
        #       of the stuff it does instead of modifying it. Here we just ignore 
        #       any modules it generates to support 'dynamic' features at runtime
        if node.Name == 'CompilerGenerated':
            WriteLine
            Write '/*** CompilerGenerated ***********************'
            WriteLine

        Visit(node.Namespace)

        if node.Imports.Count > 0:
            Visit(node.Imports)
            WriteLine()

        for member in node.Members:
            Visit(member)
            WriteLine()

        if node.Globals:
            Visit(node.Globals.Statements)

        if node.Name == 'CompilerGenerated':
            WriteLine '*** /CompilerGenerated **********************/'

    def WriteLocals(locals as LocalCollection):
    """ Write locals ensuring they are not repeated """
        found = []
        for local in locals:
            continue if local.Name == '$locals'
            continue if local.Name in found
            found.Push(local.Name)
            Visit local

    def OnMethod(m as Method):

        # Types are already resolved so we can just check if it was flagged as a generator 
        entity as TypeSystem.Internal.InternalMethod = m.Entity
        if entity.IsGenerator:
            print 'Generator'

        if m.IsRuntime:
            WriteIndented('// runtime')
            WriteLine()

        if /^\$\w+\$closure\$\d+/.IsMatch(m.Name):
            print 'Skipping closure method', m.Name
            return

        # HACK: If we detect the Main method we just output its statements
        if m.Name == 'Main':
            WriteLocals(m.Locals)
            Visit m.Body
            return

        WriteCallableDefinitionHeader('function ', m)
        WriteOpenBrace
        WriteLocals(m.Locals)
        Visit m.Body
        WriteCloseBrace

    def OnSlicingExpression(node as SlicingExpression):
        Visit node.Target
        Write '['
        Visit node.Indices[0].Begin
        Write ']'

    def OnUnpackStatement(node as UnpackStatement):
         NotImplemented(node, 'Unpack should be performed in its own step')

    def OnBlockExpression(node as BlockExpression):
    """ Javascript has native support for closures thus the conversion is very simple.
    """
        if (node.ParentNode isa MethodInvocationExpression): Write '('
        Write 'function('
        if len(node.Parameters):
            WriteCommaSeparatedList(node.Parameters)
        Write ')'
        if node.Body.IsEmpty:
            Write '{}'
        else:
            WriteOpenBrace
            Visit node.Body.Statements
            WriteCloseBrace false
        if (node.ParentNode isa MethodInvocationExpression): Write ')'


    def WriteOpenBrace():
        Write '{'
        WriteLine
        Indent
        WriteIndented

    def WriteCloseBrace(cr as bool):
        Dedent
        WriteIndented
        Write '}'
        WriteLine if cr
        WriteLine if cr
    
    def WriteCloseBrace():
        WriteCloseBrace(true)

    def WriteAnnotation(str as string):
        lines = str.Split("\n"[0])
        if len(lines) == 1:
            Write '/** ' + str + ' */'
        else:
            WriteLine '/**'
            for ln in lines:
                WriteIndented ' * '
                Write ln
                WriteLine
            WriteIndented ' */'


    def OnLocal(node as Local):
        entity = node.Entity as TypeSystem.ITypedEntity
        # We have flagged it in OverrideProcessMethodBodies
        intlocal = entity as TypeSystem.Internal.InternalLocal
        if intlocal and intlocal.OriginalDeclaration and intlocal.OriginalDeclaration.ContainsAnnotation('global'):
            return

        # TODO: Add proper type annotations
        WriteIndented
        if entity:
            WriteAnnotation "@type {$(entity.Type)}"
            Write ' '

        # Initialize value types to avoid them being 'undefined'
        if entity and entity.Type.FullName in ('int', 'uint', 'double'): #TypeSystem.TypeSystemServices.IsNumber(entity.Type):  #.FullName in ('int', 'uint', 'double'):
            Write "var $(node.Name) = 0;"
        elif entity and entity.Type.FullName in ('bool'):
            Write "var $(node.Name) = false;"
        elif entity and entity.Type.FullName in ('string'):
            Write "var $(node.Name) = '';"
        else:
            Write "var $(node.Name);"
        WriteLine

    def OnReferenceExpression(node as ReferenceExpression):
        # TODO: Check name for invalid chars?
        Map node

        if node.Entity isa Boo.Lang.Compiler.TypeSystem.Reflection.ExternalType:
            Write 'Boo.Types.'

        Write node.Name

    def OnDeclarationStatement(node as DeclarationStatement):
        # TODO: Seems like this is never used
        WriteIndented 'var '
        Map node
        Write node.Declaration.Name
        if node.Initializer:
            Write ' = '
            Visit node.Initializer
        WriteLine ';'

    def OnIfStatement(node as IfStatement):

        last_had_braces = false

        def IsElIf(block as Block):
            return false if not block
            return false if block.Statements.Count != 1
            return block.Statements[0] isa IfStatement

        def WriteCondBlock(keyword, node as IfStatement):
            Write keyword + ' ('
            Visit node.Condition
            Write ') '
            if len(node.TrueBlock.Statements):
                WriteOpenBrace 
                last_had_braces = true
                Visit(node.TrueBlock.Statements)
            else:
                WritePass

        WriteIndented
        WriteCondBlock('if', node)

        block = node.FalseBlock
        while IsElIf(block):
            stmt as IfStatement = block.Statements[0]        
            if last_had_braces:
                WriteCloseBrace false
                WriteCondBlock(' else if', stmt)
            else:
                WriteCondBlock('else if', stmt)
            block = stmt.FalseBlock

        if block:
            if last_had_braces:
                last_had_braces = false
                WriteCloseBrace false
                WriteIndented ' else '
            else:
                WriteIndented 'else '

            if len(block.Statements) > 1:
                WriteOpenBrace
                last_had_braces = true
                Visit block.Statements
            elif len(block.Statements) == 1:
                Visit block.Statements
            else:
                Write '{}'
                WriteLine

        WriteCloseBrace if last_had_braces 

    def WritePass():
        WriteLine '"pass";'

    def OnConditionalExpression(node as ConditionalExpression):
    """ Convert to the ternary operator.
            (10 if true else 20)  -->  true ? 10 : 20
    """
        WriteWithOptionalParens node.Condition
        Write ' ? '
        WriteWithOptionalParens node.TrueValue
        Write ' : '
        WriteWithOptionalParens node.FalseValue
        
    def WriteWithOptionalParens(node as Node):
        parens = NeedsParensAround(node)
        if parens:
            WriteWithParens(node)
        else:
            Visit node

    def WriteWithParens(node as Node):
        Write '('
        Visit node
        Write ')'


    def OnTryStatement(node as TryStatement):

        WriteIndented
        Write 'try '
        WriteOpenBrace
        Visit node.ProtectedBlock

        assert 1 == len(node.ExceptionHandlers)

        hdl = node.ExceptionHandlers[0]
        WriteCloseBrace false
        Write " catch ($(hdl.Declaration.Name)) "
        WriteOpenBrace

        Visit hdl.Block

        if node.EnsureBlock:
            WriteCloseBrace false
            Write ' finally '
            WriteOpenBrace
            Visit node.EnsureBlock

        WriteCloseBrace


    def OnListLiteralExpression(node as ListLiteralExpression):
    """ The List type in Boo '[,,,]' is equivalent to the JS array
    """
        WriteDelimitedCommaSeparatedList('[', node.Items, ']')

    def OnArrayLiteralExpression(node as ArrayLiteralExpression):
    """ Arrays in Boo '(,,,)' are immutable but we convert them to plain JS arrays anyway
    """
        WriteDelimitedCommaSeparatedList('[', node.Items, ']')

    def OnHashLiteralExpression(node as HashLiteralExpression):
    """ Hashes are plain Javascript objects
    """
        is_short = len(node.Items) < 3
        if is_short:
            Write '{'
        else:
            WriteOpenBrace

        first = true
        for pair as ExpressionPair in node.Items:
            if not first:
                Write ', '
                if not is_short:
                    WriteLine
                    WriteIndented

            Visit pair.First
            Write ': '
            Visit pair.Second
            first = false
        
        if is_short:
            Write '}'
        else:
            WriteCloseBrace(node.ParentNode.NodeType != NodeType.MethodInvocationExpression)

    def WriteDelimitedCommaSeparatedList(opening, list as Expression*, closing):
        Write(opening)
        WriteCommaSeparatedList(list)
        Write(closing)

    def OnLabelStatement(node as LabelStatement):
        Map node
        WriteIndented "$(node.Name):"

    def OnGotoStatement(node as GotoStatement):
        WriteIndented
        Map node
        Write "continue $(node.Label.Name);"
        WriteLine

    def OnSelfLiteralExpression(node as SelfLiteralExpression):
        Map node
        Write 'this'

    def OnCharLiteralExpression(node as CharLiteralExpression):
    """ Chars in JS are strings of length 1 """
        Map node
        WriteStringLiteral(node.Value)

    def OnStringLiteralExpression(node as StringLiteralExpression):
        Map node
        WriteStringLiteral(node.Value)

    def OnRELiteralExpression(node as RELiteralExpression):
    """ Almost a direct translation to Javascript regexp literals. The only modification
        is that we ignore whitespace to allow the regexps to be somehow more readable while
        Boo's handling is to escape it as part of the match.

            / foo | bar /i  ->  /foo|bar/i
            @/ foo | bar /  ->  /foo|bar/i
    """
        re = node.Value

        start = re.IndexOf('/')
        stop = re.LastIndexOf('/')

        mod = re[stop:]
        re = re[start:stop]

        # Ignore white space
        re = /\s|\t/.Replace(re, '')

        # Javascript does not support the single-line modifier (dot matches new lines).
        # We emulate it by converting dots to the [\s\S] expression in the regex.
        # NOTE: The algorithm will break when a dot is preceeded by an escaped back slash (\\.)
        if mod.Contains('s'):
            re = /(?<!\\)\./.Replace(re, '[\\s\\S]')
            mod = mod.Replace('s', '')

        Map node
        Write "$re$mod"

    def OnIntegerLiteralExpression(node as IntegerLiteralExpression):
        Map node
        Write(node.Value.ToString())

    def OnDoubleLiteralExpression(node as DoubleLiteralExpression):
        Map node
        Write(node.Value.ToString("########0.0##########"))
        
    def OnTypeDefinition(node as TypeDefinition):
        NotImplemented(node, "TypeDefinition should be processed in previous steps")

    def OnCallableDefinition(node as CallableDefinition):
        NotImplemented(node, "CallableDefinition should be processed in previous steps")

    def OnCallableTypeReference(node as CallableTypeReference):
        NotImplemented(node, "CallableTypeReference should be processed in previous steps")

    def OnGenericTypeDefinitionReference(node as GenericTypeDefinitionReference):
        NotImplemented(node, "GenericTypeDefinitionReference should be processed in previous steps")

    def OnExpressionStatement(node as ExpressionStatement):
        # Ignore the assignment of locals produced by closures instrumentation
        if node.Expression isa BinaryExpression:
            expr = node.Expression as BinaryExpression
            if expr.Operator == BinaryOperatorType.Assign:
                str = expr.Left.ToString()
                return if str == '$locals'

        WriteIndented
        Visit node.Expression
        Visit node.Modifier
        Write ';'
        WriteLine

    def OnExpressionInterpolationExpression(node as ExpressionInterpolationExpression):
    """ We build either as string concatenation or as a literal array and then join it to form the string
            "foo \$bar" => 'foo' + bar
            "foo \$bar \$baz" -> ['foo', bar, ' ', baz].join('')
    """
        use_join = len(node.Expressions) > 3
        concat_str = (', ' if use_join else ' + ')
    
        Write '[' if use_join
        first = true
        for arg in node.Expressions:
            if arg.NodeType == NodeType.StringLiteralExpression:
                value = (arg as StringLiteralExpression).Value
                continue if not len(value)
                Write concat_str if not first
                WriteStringLiteral((arg as StringLiteralExpression).Value)
            else:
                # TODO: Use parens around expressions if needed
                Write concat_str if not first
                Visit(arg)

            first = false

        Write "].join('')" if use_join

    def OnGeneratorExpression(node as GeneratorExpression):
        # ( i*2 for i as int in range(3) )
        NotImplemented(node, 'Generator expressions should have been normalized in a previous step')

    def OnMemberReferenceExpression(node as MemberReferenceExpression):
        # TODO: Check if the property name is a valid javascript ident and if not use ['xxx'] syntax

        # If the target is the `global` object skip it
        if node.Target.NodeType == NodeType.ReferenceExpression:
            target = node.Target as ReferenceExpression
            if target.Name == 'global':
                Write node.Name
                return
            elif target.Name == 'BooJs.Lang.BuiltinsModule':
                Write 'Boo.' + node.Name
                return
            # Check if it's a class. If so skip it by now
            # TODO: THIS DOESN'T WORK!!!
            elif false and target.ExpressionType and target.ExpressionType.BaseType.IsClass:
                Write node.Name
                return

        # Remove the $locals.$ prefix from closure variables
        if node.Target.ToString() == '$locals':
            Write node.Name[1:]
            return

        # Check if a node is bound to the main class
        def RefsMainClass(node as Node):
            if not node or not node.Entity:
                return false

            if not node.Entity isa TypeSystem.Internal.InternalClass:
                return false

            entity = node.Entity as TypeSystem.Internal.InternalClass
            if not entity.IsClass or not entity.TypeDefinition:
                return false

            defnode = entity.TypeDefinition as ClassDefinition
            if defnode.IsNested or not defnode.EnclosingModule:
                return false

            return true

        # Checks if a node is bound to a builtin type
        def RefsBuiltIn(node as Node):
            if not node or not node.Entity:
                return false

            return node.Entity.EntityType == TypeSystem.EntityType.BuiltinFunction


        # Skip the target if it's the MainClass injected by Boo
        # TODO: Move to step
        if not RefsMainClass(node.Target):
            Visit node.Target
            Write '.'

        if RefsBuiltIn(node.Target):
            print 'BUILT IN', node.Target

        Map node
        Write node.Name

        # System
        # .IsSynthetic == false
        # .Entity isa TypeSystem.Core.ResolvedNamespaces, TypeSystem.Core.AbstractNamespace
        # .Entity.EntityType == Namespace



    def OnMethodInvocationExpression(node as MethodInvocationExpression):

        # "Eval" calls take the form:
        #
        #    @( stmt1, stmt2, ...., return_stmt )
        #
        # so we can convert them to a self invoking anonymous function that returns the last
        # argument.
        #
        # Note: New variables are declared in the enclosing scope not wrapped in the anonymous
        #       function.
        #
        if '@' == node.Target.ToString():
            Write '(function(){ '
            # Execute statements passed as arguments
            l = len(node.Arguments)
            for i in range(l):
                # Return the result of the last statement
                if i == l-1:
                    Write 'return '
                Visit node.Arguments[i]
                Write '; '
            Write '})()'
            return

        Visit node.Target
        Write '('
        WriteCommaSeparatedList node.Arguments

        # TODO: What to do with named arguments?
        # Although Boo doesn't support the definition of named params it does support
        # their use when calling methods. If the method is a constructor then it automatically
        # sets those properties:
        #  Foo(x:1, y:10)   ->  function Foo(){ this.x = 1; this.y = 10
         
        #if len(node.NamedArguments):
        #    if len(node.Arguments):
        #        Write ', '
        #    WriteCommaSeparatedList node.NamedArguments

        Write ')'

    def OnReturnStatement(node as ReturnStatement):
        WriteIndented 'return '
        Visit node.Expression
        WriteLine ';'

    def OnRaiseStatement(node as RaiseStatement):
        WriteIndented 'throw '
        if node.Exception isa MethodInvocationExpression:
            Write 'new '
        Visit node.Exception
        WriteLine

    def OnWhileStatement(node as WhileStatement):
        WriteIndented 'while ('
        Visit node.Condition
        Write ') '
        WriteOpenBrace
        Visit node.Block
        WriteCloseBrace

    def OnUnlessStatement(node as UnlessStatement):
        WriteIndented 'if (! '
        WriteWithOptionalParens node.Condition
        Write ') '
        WriteOpenBrace
        Visit(node.Block)
        WriteCloseBrace

    def OnBreakStatement(node as BreakStatement):
        WriteIndented
        Map node
        WriteLine 'break;'

    def OnContinueStatement(node as ContinueStatement):
        WriteIndented 
        Map node
        WriteLine 'continue;'

    def OnCastExpression(node as CastExpression):
        Write 'Boo.Lang.cast('
        Visit node.Target
        Write ', '
        Visit node.Type
        Write ')'

    def OnTryCastExpression(node as TryCastExpression):
        Write 'Boo.Lang.trycast('
        Visit node.Target
        Write ', '
        Visit node.Type
        Write ')'

    def OnUnaryExpression(node as UnaryExpression):
        # Make sure negation applies correctly to its operand
        if node.Operator == UnaryOperatorType.LogicalNot:
            Write '!('
            Visit node.Operand
            Write ')'
            return

        Write '(' if NeedsParensAround(node)

        isPostOp = AstUtil.IsPostUnaryOperator(node.Operator)
        Write GetUnaryOperatorText(node) if not isPostOp
        parens = NeedsParensAround(node.Operand)
        Write '(' if parens
        Visit node.Operand
        Write ')' if parens
        Write GetUnaryOperatorText(node) if isPostOp

        Write ')' if NeedsParensAround(node)

    def GetUnaryOperatorText(node as UnaryExpression):
        op = node.Operator
        # TODO: In ProcessMethod.ExpandSimpleIncrementDecrement this is expanded
        if op == UnaryOperatorType.PostIncrement or op == UnaryOperatorType.Increment:
            return '++'
        # TODO: In ProcessMethod.ExpandSimpleIncrementDecrement this is expanded
        elif op == UnaryOperatorType.PostDecrement or op == UnaryOperatorType.Decrement:
            return '--'
        elif op == UnaryOperatorType.UnaryNegation:
            return '-'
        elif op == UnaryOperatorType.LogicalNot:
            return '!'
        elif op == UnaryOperatorType.OnesComplement:
            return '~'
        elif op == UnaryOperatorType.Explode:
            NotImplemented(node, 'Explode operator "*" is not supported')
        elif op == UnaryOperatorType.AddressOf:
            NotImplemented(node, 'AddressOf operator "&" is not supported')
        elif op == UnaryOperatorType.Indirection:
            NotImplemented(node, 'Indirection operator "*" is not supported')
        else:
            NotImplemented(node, "Invalid operator \"$op\"")

    def BinaryAssign(node as BinaryExpression):
        # Wrap in parens if it's an assigment inside an expression
        parens = not node.ParentNode isa Statement
        Write '(' if parens

        Visit node.Left
        Write ' = '
        Visit node.Right

        Write ')' if parens

    def BinaryExponentiation(node as BinaryExpression):
        Write 'Math.pow('
        Visit node.Left
        Write ', '
        Visit node.Right
        Write ')'

    def BinaryMatch(node as BinaryExpression):
        type = TypeSystem.TypeSystemServices.GetExpressionType(node.Right)
        if type.FullName == 'BooJs.Lang.RegExp':
            Visit node.Right
        else: #if type.FullName == 'String':
            Write '(new RegExp('
            Visit node.Right
            Write '))'

        Write '.test('
        Visit node.Left
        Write ')'


    def OnBinaryExpression(node as BinaryExpression):

        if node.Operator == BinaryOperatorType.Assign:
            BinaryAssign(node)
        elif node.Operator == BinaryOperatorType.Exponentiation:
            BinaryExponentiation(node)
        elif node.Operator == BinaryOperatorType.Match: # a =~ b
            BinaryMatch(node)
        elif node.Operator == BinaryOperatorType.NotMatch: # a !~ b
            # TODO: If we have a runtime we can match regexp too
            Write '(-1 === '
            Visit node.Left
            Write '.indexOf('
            Visit node.Right
            Write '))'
        elif node.Operator == BinaryOperatorType.NotMember: # a not in b -> !(a in b)
            Write '!('
            Visit node.Left
            Write ' in '
            Visit node.Right
            Write ')'
        elif node.Operator == BinaryOperatorType.TypeTest: # a isa type -> typeof a === 'type'  OR  a instanceof type
            # isa rhs is encoded in a typeof expression
            if node.Right isa TypeofExpression \
            and (node.Right as TypeofExpression).Type isa SimpleTypeReference:
                # TODO: We need to convert type names to JS ones somewhere
                # TODO: Shall we also check for instanceof Number, String, Array... ???
                type = (node.Right as TypeofExpression).Type as SimpleTypeReference

                if type.Name.IndexOf('Error') >= 0:
                    Visit node.Left
                    Write ' instanceof '
                    Visit node.Right
                else:
                    Write 'typeof '
                    Visit node.Left
                    Write " === "
                    if type.Name == 'bool':
                        Write "'boolean'"
                    elif type.Name == 'int' or type.Name == 'uint' or type.Name == 'double':
                        Write "'number'"
                    elif type.Name == 'void':
                        Write "'undefined'"
                    elif type.Name == 'callable':
                        Write "'function'"
                    else:
                        Write "'$(type.Name)'"

            else:
                Visit node.Left
                Write ' instanceof '
                Visit node.Right

        else:
            # HACK: Why doesn't Boo does this automatically?
            lefttype = TypeSystem.TypeSystemServices.GetExpressionType(node.Left)
            if lefttype.FullName == 'BooJs.Lang.Array':
                Write 'Boo.Lang.Array.op_Addition('
                Visit node.Left
                Write ', '
                Visit node.Right
                Write ')'
                return

            parens = NeedsParensAround(node)
            Write '(' if parens
            Visit node.Left
            Write " "
            Write GetBinaryOperatorText(node)
            Write " "
            Visit node.Right
            Write ')' if parens

    def OnSimpleTypeReference(node as SimpleTypeReference):
        # TODO: Why is this happending?
        if node.ToString() == 'System.Object' or node.ToString() == 'object' or node.ToString() == 'System.MulticastDelegate':
            print 'WARNING: SimpleTypeReference = ', node
            return

        if node.Name.IndexOf('BooJs.Lang.') == 0:
            Write node.Name.Substring('BooJs.Lang.'.Length)
        else:
            Write 'Boo.Types.' + node.Name


    def GetBinaryOperatorText(node as BinaryExpression):
        op = node.Operator

        return '=' if op == BinaryOperatorType.Assign
        # Note: We use equality in value and type in JS
        return '==' if op == BinaryOperatorType.Equality
        return '!=' if op == BinaryOperatorType.Inequality
        return '+' if op == BinaryOperatorType.Addition
        return '-' if op == BinaryOperatorType.Subtraction
        return '*' if op == BinaryOperatorType.Multiply
        return '/' if op == BinaryOperatorType.Division
        return '%' if op == BinaryOperatorType.Modulus
        return '+=' if op == BinaryOperatorType.InPlaceAddition
        return '-=' if op == BinaryOperatorType.InPlaceSubtraction
        return '*=' if op == BinaryOperatorType.InPlaceMultiply
        return '%=' if op == BinaryOperatorType.InPlaceModulus
        return '/=' if op == BinaryOperatorType.InPlaceDivision
        return '&=' if op == BinaryOperatorType.InPlaceBitwiseAnd
        return '|=' if op == BinaryOperatorType.InPlaceBitwiseOr
        return '^=' if op == BinaryOperatorType.InPlaceExclusiveOr
        return '>' if op == BinaryOperatorType.GreaterThan
        return '>=' if op == BinaryOperatorType.GreaterThanOrEqual
        return '<' if op == BinaryOperatorType.LessThan
        return '<=' if op == BinaryOperatorType.LessThanOrEqual

        # TODO: Does it work most of the time???
        return 'in' if op == BinaryOperatorType.Member

        return '===' if op == BinaryOperatorType.ReferenceEquality
        return '!==' if op == BinaryOperatorType.ReferenceInequality

        return 'instanceof' if op == BinaryOperatorType.TypeTest
        return '||' if op == BinaryOperatorType.Or
        return '&&' if op == BinaryOperatorType.And

        return '|' if op == BinaryOperatorType.BitwiseOr
        return '&' if op == BinaryOperatorType.BitwiseAnd
        return '^' if op == BinaryOperatorType.ExclusiveOr
        return '<<' if op == BinaryOperatorType.ShiftLeft
        return '>>' if op == BinaryOperatorType.ShiftRight
        return '<<=' if op == BinaryOperatorType.InPlaceShiftLeft
        return '>>=' if op == BinaryOperatorType.InPlaceShiftRight

        NotImplemented(node, "Operator $(op) is not implemented")

    def NeedsParensAround(node as Expression):
        return true if node.ParentNode and node.ParentNode.NodeType == NodeType.MemberReferenceExpression  # (--1).toString()
        t = node.NodeType
        return false if t == NodeType.StringLiteralExpression
        return false if t == NodeType.CharLiteralExpression
        return false if t == NodeType.BoolLiteralExpression
        return false if t == NodeType.IntegerLiteralExpression
        return false if t == NodeType.DoubleLiteralExpression
        return false if t == NodeType.NullLiteralExpression
        return false if t == NodeType.ReferenceExpression
        return false if t == NodeType.ListLiteralExpression
        return false if t == NodeType.ArrayLiteralExpression
        return false if t == NodeType.MethodInvocationExpression
        return false if t == NodeType.UnaryExpression
        
        # TODO: Not very sure about this
        if node.ParentNode:
            t = node.ParentNode.NodeType
            return false if t == NodeType.ExpressionStatement
            #return false if t == NodeType.IfStatement
            #return false if t == NodeType.WhileStatement
            #return false if t == NodeType.UnlessStatement

        return true


    def WriteCallableDefinitionHeader(keyword as string, node as CallableDefinition):
        # TODO: Inspect params and return to generate type annotations for Closure
        WriteIndented keyword
        Map node
        Write node.Name
        WriteParameterList(node.Parameters, '(', ')')

    def WriteParameterList(params as ParameterDeclarationCollection, st, ed):
        Write(st)
        i = 0
        for param in params:
            if i > 0:
                Write(', ')
            Visit(param)
            i++
        Write(ed)

    def OnParameterDeclaration(p as ParameterDeclaration):
        #if p.IsParamArray: Write("*")
        Map(p)
        Write(p.Name);


    def OnEnumDefinition(node as EnumDefinition):
        # TODO: Prefix with namespace
        Write 'var '

        Map node
        Write "$(node.FullName) = "
        WriteOpenBrace
        first = true
        for member as EnumMember in node.Members:
            assert member.Initializer != null, 'Enum definition without an initializer value!'
            WriteLine ',' if not first
            WriteIndented
            Map member
            Write member.Name
            Write ': '
            Visit member.Initializer
            first = false
            
        WriteLine
        WriteCloseBrace

    def OnClassDefinition(node as ClassDefinition):
        for member as TypeMember in node.Members:
            Visit member

        return
        /*

        Write "$(node.Name) = function()"
        WriteOpenBrace

        if len(node.BaseTypes):
            Write '// extends '
            WriteCommaSeparatedList(node.BaseTypes)
            WriteLine

        statics = []
        methods = []
        for member as TypeMember in node.Members:
            # Static members are defined outside the constructor
            if member.IsStatic:
                statics.Push(member)
                continue

            # Call the constructor method
            if member isa Constructor:
                WriteIndented 'this.constructor.apply(this, arguments);'
                WriteLine

            # Collect to define the prototype
            if member isa Method:
                methods.Push(member)
                continue

            WriteIndented 
            Visit(member)
            WriteLine()

        WriteCloseBrace

        # Setup the static fields
        for member as TypeMember in statics:
            # Inline the static constructor
            if member isa Constructor:
                Visit((member as Constructor).Body)
                continue

            WriteIndented "$(member.FullName) = "
            Visit(member)
            WriteLine

        # Setup prototype
        for member as TypeMember in methods:
            WriteIndented member.DeclaringType.FullName
            Write ".prototype.$(member.Name) = "
            Visit(member)
            WriteLine
        */


    def OnField(node as Field):
        #NotImplemented(node, "Field nodes not supported yet") 
        pass

    def OnConstructor(node as Constructor):
        #NotImplemented(node, "Constructor nodes not supported yet") 
        pass

    def OnExpressionPair(node as ExpressionPair):
        Visit node.First
        Write ': '
        Visit node.Second


    def WriteStringLiteral(text as string):
        WriteStringLiteral text, "'"

    def WriteStringLiteral(text as string, quote as string):
        Write quote
        WriteStringContent text, quote
        Write quote

    def WriteStringContent(text as string, quote as string):
        for ch in text:
            str = ch.ToString()  # Convet to string from char
            if str == '\r':
                Write '\\r'
            elif str == '\n':
                Write '\\n'
            elif str == '\t':
                Write '\\t'
            elif str == '\0':
                Write '\\0'
            elif str == '\\':
                Write '\\\\'
            elif str == "'" and str == quote:
                Write "\\'"
            elif str == '"' and str == quote:
                Write '\\"'
            else:
                Write(str)




class PrintBooJs(PrintBoo):

    override def Run():
        visitor = BooJsPrinterVisitor(OutputWriter)
        visitor.Initialize(Context)
        visitor.Print(CompileUnit);


