namespace BooJs.Compiler.Steps

import Boo.Lang.Compiler
import Boo.Lang.Compiler.Steps
import Boo.Lang.Compiler.Ast
import Boo.Lang.PatternMatching

import BooJs.Compiler.SourceMap


class BooJsPrinterVisitor(Visitors.TextEmitter):

    _context as CompilerContext
    
    srcmap as MapBuilder

    Line as int

    def constructor(writer as System.IO.TextWriter):
        super(writer)
        IndentText = '  '
        
        srcmap = MapBuilder()

    def Initialize(context as CompilerContext):
        _context = context
        for inp in context.Parameters.Input:
            srcmap.AddSource(inp.Name)

    def Print(ast as CompileUnit):
        Line = 0
        OnCompileUnit(ast)

        if false and not len(_context.Errors):
            WriteLine '//@ sourceMappingURL=map.js.map'
            WriteLine '/*'
            Write srcmap.ToString()
            WriteLine
            WriteLine '*/'

    protected def NotImplemented(node as Node, msg as string):
        raise CompilerErrorFactory.NotImplemented(node, msg)

    def WriteLine():
        srcmap.NewLine()
        Line++
        super()
        
    def Write(str as string):
        srcmap.Column += str.Length
        super(str)

    def Map(node as Node):
    """ Maps the given node lexical info to the current position in the generated file
    """
        srcmap.Segment(node)


    #### Literals ###########################################################

    def OnBoolLiteralExpression(node as BoolLiteralExpression):
        Write( ('true' if node.Value else 'false') )

    def OnNullLiteralExpression(node as NullLiteralExpression):
        Write 'null'

    def OnSelfLiteralExpression(node as SelfLiteralExpression):
        Map node
        Write 'this'

    def OnCharLiteralExpression(node as CharLiteralExpression):
    """ Chars in JS are strings of length 1 """
        #TODO: Move this to clean step?
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

        TODO: The ones prefixed with @ should preserve white space
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

    def OnListLiteralExpression(node as ListLiteralExpression):
    """ The List type in Boo '[,]' is equivalent to the JS array
    """
        WriteDelimitedCommaSeparatedList('[', node.Items, ']')

    def OnArrayLiteralExpression(node as ArrayLiteralExpression):
    """ Arrays in Boo '(,)' are immutable but we convert them to plain JS arrays anyway
    """
        # TODO: Do this in the Cleanup step?
        WriteDelimitedCommaSeparatedList('[', node.Items, ']')

    def OnHashLiteralExpression(node as HashLiteralExpression):
    """ Hashes are plain Javascript objects
    """
        is_short = len(node.Items) < 3
        if is_short:
            Write '{'
        else:
            WriteOpenBrace

        for idx as int, pair as ExpressionPair in enumerate(node.Items):
            if idx > 0:
                Write ', '
                if not is_short:
                    WriteLine
                    WriteIndented

            Visit pair.First
            Write ': '
            Visit pair.Second

        if is_short:
            Write '}'
        else:
            WriteCloseBrace


    #### Type declarations ##################################################

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
            Visit(node.Globals) #.Statements)

        if node.Name == 'CompilerGenerated':
            WriteLine '*** /CompilerGenerated **********************/'

    def OnClassDefinition(node as ClassDefinition):
        for member as TypeMember in node.Members:
            Visit member
            if member.NodeType in (NodeType.Method,):
                WriteLine
                WriteLine
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
        return

    def OnField(node as Field):
        #NotImplemented(node, "Field nodes not supported yet")
        pass

    def OnConstructor(node as Constructor):
        #NotImplemented(node, "Constructor nodes not supported yet")
        pass

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

        # TODO: Move to clean up?
        if m.Name == 'Main':
            WriteLocals(m.Locals)
            Visit m.Body
            return

        WriteCallableDefinitionHeader('function ', m)
        WriteOpenBrace
        WriteLocals(m.Locals)
        Visit m.Body
        WriteCloseBrace

    def OnParameterDeclaration(p as ParameterDeclaration):
        #if p.IsParamArray: Write("*")
        Map(p)
        Write(p.Name)


    #### Flow control #######################################################

    def OnIfStatement(node as IfStatement):

        last_had_braces = false

        def IsElIf(block as Block):
            return false if not block
            return false if len(block.Statements) != 1
            return block.FirstStatement isa IfStatement

        def WriteCondBlock(keyword, node as IfStatement):
            Write keyword + ' ('
            Visit node.Condition
            Write ') '
            // Nested ifs are also wrapped in braces
            if len(node.TrueBlock.Statements) > 1 or IsElIf(node.TrueBlock):
                WriteOpenBrace
                last_had_braces = true
                Visit(node.TrueBlock)
            elif not node.TrueBlock.IsEmpty:
                Visit node.TrueBlock
            else:
                WritePass

        WriteCondBlock('if', node)

        block = node.FalseBlock
        while IsElIf(block):
            stmt as IfStatement = block.FirstStatement
            if last_had_braces:
                WriteCloseBrace
                WriteCondBlock(' else if', stmt)
            else:
                WriteIndented
                WriteCondBlock('else if', stmt)
            block = stmt.FalseBlock

        if block:
            if last_had_braces:
                last_had_braces = false
                WriteCloseBrace
                WriteIndented ' else '
            else:
                WriteIndented 'else '

            if len(block.Statements) > 1:
                WriteOpenBrace
                last_had_braces = true
                Visit block.Statements
            elif not block.IsEmpty:
                Visit block
            else:
                Write '{}'

        WriteCloseBrace if last_had_braces

    def OnWhileStatement(node as WhileStatement):
        WriteIndented 'while ('
        Visit node.Condition
        Write ') '
        WriteOpenBrace
        Visit node.Block
        WriteCloseBrace

    def OnTryStatement(node as TryStatement):
        Write 'try '
        WriteOpenBrace
        Visit node.ProtectedBlock

        assert 1 == len(node.ExceptionHandlers), 'Multiple exceptions handlers should be processed in previous steps'

        hdl = node.ExceptionHandlers[0]
        WriteCloseBrace
        Write " catch ($(hdl.Declaration.Name)) "
        WriteOpenBrace

        Visit hdl.Block

        if node.EnsureBlock:
            WriteCloseBrace
            Write ' finally '
            WriteOpenBrace
            Visit node.EnsureBlock

        WriteCloseBrace

    def OnBreakStatement(node as BreakStatement):
        WriteIndented
        Map node
        WriteLine 'break'

    def OnContinueStatement(node as ContinueStatement):
        WriteIndented
        Map node
        WriteLine 'continue'

    def OnLabelStatement(node as LabelStatement):
        Map node
        Write "$(node.Name):"

    def OnGotoStatement(node as GotoStatement):
        Map node
        Write "continue $(node.Label.Name)"

    def OnReturnStatement(node as ReturnStatement):
        WriteIndented 'return '
        Visit node.Expression

    def OnRaiseStatement(node as RaiseStatement):
        WriteIndented 'throw '
        # TODO: We should make sure it's a constructor
        if node.Exception isa MethodInvocationExpression:
            Write 'new '
        Visit node.Exception


    #### Statements #########################################################

    def OnBlock(node as Block):
        for st in node.Statements:
            ln = Line

            WriteIndented
            Visit st

            if st is node.LastStatement:
                WriteLine
            else:
                if st.NodeType not in (NodeType.IfStatement, NodeType.TryStatement):
                    Write ';'
                WriteLine

                if Line-ln > 2:
                    WriteLine

    def OnExpressionStatement(node as ExpressionStatement):
        Visit node.Expression
        Visit node.Modifier


    #### Expressions ########################################################

    def OnReferenceExpression(node as ReferenceExpression):
        Map node
        Write node.Name

    def OnMemberReferenceExpression(node as MemberReferenceExpression):
        Visit node.Target
        Write '.'
        Map node
        Write node.Name

    def OnSimpleTypeReference(node as SimpleTypeReference):
        # TODO: Move this to cleanup
        if node.Name.IndexOf('BooJs.Lang.Globals.') == 0:
            Write node.Name.Substring('BooJs.Lang.Globals.'.Length)
        elif node.Name.IndexOf('BooJs.Lang.Builtins.') == 0:
            Write 'Boo.' + node.Name.Substring('BooJs.Lang.Builtins.'.Length)
        else:
            Write 'Boo.Types.' + node.Name

    def OnLocal(node as Local):
        entity = node.Entity as TypeSystem.ITypedEntity
        # We have flagged it in OverrideProcessMethodBodies
        intlocal = entity as TypeSystem.Internal.InternalLocal
        if intlocal and intlocal.OriginalDeclaration and intlocal.OriginalDeclaration.ContainsAnnotation('global'):
            return

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

    def OnConditionalExpression(node as ConditionalExpression):
    """ Convert to the ternary operator.
            (10 if true else 20)  -->  true ? 10 : 20
    """
        WriteWithOptionalParens node.Condition
        Write ' ? '
        WriteWithOptionalParens node.TrueValue
        Write ' : '
        WriteWithOptionalParens node.FalseValue

    def OnExpressionPair(node as ExpressionPair):
        Visit node.First
        Write ': '
        Visit node.Second

    def OnSlicingExpression(node as SlicingExpression):
        Visit node.Target
        Write '['
        Visit node.Indices[0].Begin
        Write ']'

    def OnCastExpression(node as CastExpression):
        # TODO: Move this to a step
        Write 'Boo.cast('
        Visit node.Target
        Write ', '
        Visit node.Type
        Write ')'

    def OnTryCastExpression(node as TryCastExpression):
        # TODO: Move this to a step
        Write 'Boo.trycast('
        Visit node.Target
        Write ', '
        Visit node.Type
        Write ')'

    def OnExpressionInterpolationExpression(node as ExpressionInterpolationExpression):
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

    def OnMethodInvocationExpression(node as MethodInvocationExpression):
        return if ApplyTransform(node, node.Arguments.ToArray())

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

        # Use new for constructors
        entity = node.Target.Entity as TypeSystem.IConstructor
        if entity:
            Write 'new '

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

    def OnUnaryExpression(node as UnaryExpression):
        # We have to wrap negation in parens to ensure we don't break when using the JsRewrite attribute
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

    def OnBinaryExpression(node as BinaryExpression):

        match node:
            case [| $a = $b |]:
                BinaryAssign(node)
            case [| $a =~ $b |]:
                BinaryMatch(node)
            case [| $a !~ $b |]:
                Write '!'
                BinaryMatch(node)
            case [| $a not in $b |]:
                Write '!('
                Visit node.Left
                Write ' in '
                Visit node.Right
                Write ')'
            # TODO: It seems that we cannot match this expression
            #case [| $a isa $b |]:
            #    Visit node.Left
            #    Write ' instanceof '
            #    Visit node.Right
            otherwise:
                parens = NeedsParensAround(node)
                Write '(' if parens
                Visit node.Left
                Write " "
                Write GetBinaryOperatorText(node)
                Write " "
                Visit node.Right
                Write ')' if parens

        /*
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
        */
        return

    def OnBlockExpression(node as BlockExpression):
    """ Javascript has native support for closures thus the conversion is very simple.
    """
        Write '(' if NeedsParensAround(node)
        Write 'function ('
        if len(node.Parameters):
            WriteCommaSeparatedList(node.Parameters)
        Write ') '
        if node.Body.IsEmpty:
            Write '{}'
        else:
            WriteOpenBrace
            Visit node.Body
            WriteCloseBrace
        Write ')' if NeedsParensAround(node)


    #### Unsupported  #######################################################

    def OnUnpackStatement(node as UnpackStatement):
        NotImplemented(node, 'Unpack should be performed in its own step')

    def OnTypeDefinition(node as TypeDefinition):
        NotImplemented(node, "TypeDefinition should be processed in previous steps")

    def OnCallableDefinition(node as CallableDefinition):
        NotImplemented(node, "CallableDefinition should be processed in previous steps")

    def OnCallableTypeReference(node as CallableTypeReference):
        NotImplemented(node, "CallableTypeReference should be processed in previous steps")

    def OnGenericTypeDefinitionReference(node as GenericTypeDefinitionReference):
        NotImplemented(node, "GenericTypeDefinitionReference should be processed in previous steps")

    def OnGeneratorExpression(node as GeneratorExpression):
        # ( i*2 for i as int in range(3) )
        NotImplemented(node, 'Generator expressions should have been normalized in a previous step')

    def OnUnlessStatement(node as UnlessStatement):
        NotImplemented(node, 'Unless statements should have been normalized in a previous step')

    def OnDeclarationStatement(node as DeclarationStatement):
        NotImplemented(node, 'Declaration statements should be processed in previous steps')

        # TODO: Seems like this is never used
        WriteIndented 'var '
        Map node
        Write node.Declaration.Name
        if node.Initializer:
            Write ' = '
            Visit node.Initializer
        WriteLine ';'


    def ApplyTransform(node as Node, args as (Node)) as bool:
        return false if not node.ContainsAnnotation('JsTransform')

        Map node
        parts = /(\$\d+)/.Split(node['JsTransform'])
        for part in parts:
            if /^\$\d+$/.IsMatch(part):
                idx = int.Parse(part[1:])
                if idx < 0 or idx > len(args):
                    # TODO: Use compiler error
                    raise 'Invalid argument index {0}' % (idx,)
                Visit args[idx]
            else:
                Write part
        return true

    def WriteLocals(locals as LocalCollection):
    """ Write locals ensuring they are not repeated """
        # TODO: Filter locals in Clean step
        found = []
        for local in locals:
            continue if local.Name == '$locals'
            continue if local.Name in found
            found.Push(local.Name)
            Visit local

        WriteLine if len(found)

    def WriteOpenBrace():
        Write '{'
        WriteLine
        Indent
        WriteIndented

    def WriteCloseBrace():
        Dedent
        WriteIndented
        Write '}'

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

    def WritePass():
        WriteLine '"pass";'

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

    def WriteDelimitedCommaSeparatedList(opening, list as Expression*, closing):
        Write(opening)
        WriteCommaSeparatedList(list)
        Write(closing)

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

    def BinaryAssign(node as BinaryExpression):
        # Wrap in parens if it's an assigment inside an expression
        parens = not node.ParentNode isa Statement
        Write '(' if parens

        Visit node.Left
        Write ' = '
        Visit node.Right

        Write ')' if parens

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

    def NeedsParensAround(node as Expression):
        # BlockExpressions can be called directly, in which case we need to wrap them
        if node.NodeType == NodeType.BlockExpression:
            parent = node.ParentNode as MethodInvocationExpression
            if parent and parent.Target is node:
                return true

        return false if node.NodeType in (
            NodeType.NullLiteralExpression,
            NodeType.BoolLiteralExpression,
            NodeType.CharLiteralExpression,
            NodeType.StringLiteralExpression,
            NodeType.IntegerLiteralExpression,
            NodeType.DoubleLiteralExpression,
            NodeType.ReferenceExpression,
            NodeType.ListLiteralExpression,
            NodeType.ArrayLiteralExpression,
            NodeType.UnaryExpression,
            NodeType.BinaryExpression,
            NodeType.MethodInvocationExpression,
            NodeType.BlockExpression,
            NodeType.Method,
        )
        
        return true

    def WriteCallableDefinitionHeader(keyword as string, node as CallableDefinition):
        # TODO: Inspect params and return to generate type annotations for Closure
        WriteIndented keyword
        Map node
        Write node.Name
        Write ' '
        WriteParameterList(node.Parameters, '(', ')')
        Write ' '

    def WriteParameterList(params as ParameterDeclarationCollection, st, ed):
        Write(st)
        i = 0
        for param in params:
            if i > 0:
                Write(', ')
            Visit(param)
            i++
        Write(ed)

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
        visitor.Print(CompileUnit)


