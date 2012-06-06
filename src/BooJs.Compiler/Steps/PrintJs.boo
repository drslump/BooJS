namespace Boojs.Compiler.Steps

import Boo.Lang.Compiler.Steps
import Boo.Lang.Compiler.Ast
import Boo.Lang.Compiler


class JsPrinterVisitor(Visitors.TextEmitter):

    _context as CompilerContext

    def constructor(writer as System.IO.TextWriter):
        super(writer)
        IndentText = '  '

    def Initialize(context as CompilerContext):
        _context = context


    def Print(ast as CompileUnit):
        OnCompileUnit(ast)

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
            Write '--------------'
            WriteLine
            Write ' CompiledGenerated'
            WriteLine
            Write '--------------'
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

        for attr in node.Attributes:
            WriteAttribute(attr, 'module: ')
            WriteLine();

        for attr in node.AssemblyAttributes:
            WriteAttribute(attr, 'assembly: ')
            WriteLine()


    def WriteLocals(locals as LocalCollection):
    """ Write locals ensuring they are not repeated """
        found = []
        for local in locals:
            continue if local.Name in found
            found.Push(local.Name)
            Visit local
            WriteLine

    def OnMethod(m as Method):

        # Types are already resolved so we can just check if it was flagged as a generator 
        entity as TypeSystem.Internal.InternalMethod = m.Entity
        if entity.IsGenerator:
            print 'Generator'

        if m.IsRuntime:
            WriteIndented('// runtime')
            WriteLine()


        # HACK: If we detect the Main method we just output its statements
        if m.Name == 'Main':
            WriteLocals(m.Locals)
            Visit m.Body
            return

        WriteCallableDefinitionHeader('function ', m)
        if IsInterfaceMember(m):
            WriteLine()
        else:
            WriteOpenBrace
            WriteLocals(m.Locals)
            Visit m.Body
            WriteCloseBrace

    def OnSlicingExpression(node as SlicingExpression):
        if len(node.Indices) != 1:
            raise 'Only one index is supported when slicing'

        Visit node.Target
        Write '['
        Visit node.Indices[0]
        Write ']'

    def OnBlockExpression(node as BlockExpression):
    """ Javascript has native support for closures thus the conversion is very simple.
    """
        Write 'function('
        if len(node.Parameters):
            WriteCommaSeparatedList(node.Parameters)
        Write ')'
        if node.Body.IsEmpty:
            Write '{}'
        elif len(node.Body.Statements) == 1 \
        and  len(node.Body.Statements[0].ToString()) < 30:
            # TODO: When it's just one statement we should inject a return if not present
            #       Seems like Boo already does that :)
            Write '{'
            Visit node.Body.Statements[0]
            Write '}'
        else:
            WriteOpenBrace
            Visit(node.Body.Statements)
            WriteCloseBrace false

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

    def OnLocal(node as Local):
        ilocal = node.Entity as Boo.Lang.Compiler.TypeSystem.ITypedEntity
        # HACK: We should find a better way to compare the type. If it matches 
        #       the special global type (ie: jQuery as global) then we avoid defining
        #       it, which would shadow the global variable
        #if ilocal.Type.ToString() == 'Boojs.Lang.global':
        #    return

        # TODO: Add type annotations
        WriteIndented
        WriteLine "var $(node.Name);"

    def OnReferenceExpression(node as ReferenceExpression):
        # TODO: Check name for invalid chars?
        Write(node.Name)

    def OnDeclarationStatement(node as DeclarationStatement):
        WriteIndented "var $(node.Declaration.Name)"
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
            if len(node.TrueBlock.Statements) > 1:
                WriteOpenBrace 
                last_had_braces = true
                Visit(node.TrueBlock.Statements)
            elif len(node.TrueBlock.Statements) == 1:
                last_had_braces = false
                Visit(node.TrueBlock.Statements[0])
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
                WritePass

        WriteCloseBrace if last_had_braces 

    def WritePass():
        WriteLine '// pass'

    def OnConditionalExpression(node as ConditionalExpression):
    """ Convert to the ternary operator.
            (10 if true else 20)  -->  true ? 10 : 20
    """
        Write '('
        Visit node.Condition
        Write ') ? '

        parens = NeedsParensAround(node.TrueValue)
        Write '(' if parens
        Visit node.TrueValue
        Write ')' if parens
        Write ' : '

        parens = NeedsParensAround(node.FalseValue)
        Write '(' if parens
        Visit node.FalseValue
        Write ')' if parens

    def OnArrayLiteralExpression(node as ArrayLiteralExpression):
    """ Arrays in Boo are immutable but we convert them to plain JS arrays anyway
    """ 
        WriteDelimitedCommaSeparatedList('[', node.Items, ']')

    def OnHashLiteralExpression(node as HashLiteralExpression):
    """ Hashes are plain Javascript objects
    """
        is_short = len(node.Items) < 4
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
        WriteIndented "$(node.Name):"

    def OnGotoStatement(node as GotoStatement):
        WriteIndented "continue $(node.Label.Name);"
        WriteLine

    def OnSelfLiteralExpression(node as SelfLiteralExpression):
        Write 'this'

    def OnCharLiteralExpression(node as CharLiteralExpression):
    """ Chars in JS are strings of length 1 """
        WriteStringLiteral(node.Value)

    def OnStringLiteralExpression(node as StringLiteralExpression):
        WriteStringLiteral(node.Value)

    def OnRELiteralExpression(node as RELiteralExpression):
    """ Almost a direct translation to Javascript regexp literals. The only modification
        is that we ignore whitespace to allow the regexps to be somehow more readable while
        Boo's handling is to escape it as part of the match.

            /foo|bar/i      ->  /foo|bar/i
            @/ foo | bar /  ->  /foo|bar/i
    """
        re = node.Value
        mod = re[-1:]
        if mod == '/':
            re = re[1:-1]
            mod = ''
        else:
            re = re[1:-2]

        # Ignore white space
        re = /\s|\t/.Replace(re, '')

        Write "/$re/$mod"

    def OnIntegerLiteralExpression(node as IntegerLiteralExpression):
        Write(node.Value.ToString())

    def OnDoubleLiteralExpression(node as DoubleLiteralExpression):
        Write(node.Value.ToString("########0.0##########")) #, CultureInfo.InvariantCulture))


    def OnExpressionStatement(node as ExpressionStatement):
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
  

    def OnMemberReferenceExpression(node as MemberReferenceExpression):
        # TODO: Check if the property name is a valid javascript ident and if not use ['xxx'] syntax

        raise "FOO"

        # If the target is the `global` object skip it
        if node.Target.NodeType == NodeType.ReferenceExpression:
            target = node.Target as ReferenceExpression
            if target.Name == 'global':
                Write node.Name
                return

        Visit node.Target
        Write '.'
        Write node.Name



    def OnMethodInvocationExpression(node as MethodInvocationExpression):

        # TODO: We can use something like this to know which overloaded method we are calling
        /*
        print 'Target: ', node.Target.Entity
        entity as TypeSystem.IEntityWithParameters = node.Target.Entity
        if entity:
            # TODO: Check varargs ?
            i = 0
            for param as TypeSystem.IParameter in entity.GetParameters():
                print 'Arg: ', node.Arguments[i]
                print 'Param: ', param
                print 'Param.Type: ', param.Type
                i++
        */



        # HACK: Boo converts the equality comparison to a runtime call for those atoms
        #       without an static type on the complex ProcessMethodBodies step.
        #       Instead of changing that step we undo the transformation since it's
        #       much simple although very dirty :(
        # TODO: Although we keep this hack it should be moved to its own dedicated step

        def UndoOperatorInvocation(node as MethodInvocationExpression, operator as BinaryOperatorType):
            expr = BinaryExpression(node.LexicalInfo)
            expr.Operator = operator
            expr.Left = node.Arguments[0]
            expr.Right = node.Arguments[1]
            Visit expr

        tref = node.Target.ToString()
        if tref == 'Boo.Lang.Runtime.RuntimeServices.EqualityOperator':
            UndoOperatorInvocation(node, BinaryOperatorType.Equality)
            return
        elif tref == 'Boo.Lang.Runtime.RuntimeServices.op_Match':
            UndoOperatorInvocation(node, BinaryOperatorType.Match)
            return
        elif tref == 'Boo.Lang.Runtime.RuntimeServices.op_NotMatch':
            UndoOperatorInvocation(node, BinaryOperatorType.NotMatch)
            return
        elif tref == 'Boo.Lang.Runtime.RuntimeServices.op_Member':
            UndoOperatorInvocation(node, BinaryOperatorType.Member)
            return
        elif tref == 'Boo.Lang.Runtime.RuntimeServices.op_NotMember':
            UndoOperatorInvocation(node, BinaryOperatorType.NotMember)
            return
        elif tref == 'Boo.Lang.Runtime.RuntimeServices.GetEnumerable':
            Visit node.Arguments[0]
            return
        elif tref =~ 'Boo.Lang.Runtime.RuntimeServices':
            raise "Found a RuntimeServices invocation: $tref"

        # Revert: CompilerGenerated.__FooModule_foo$callable0$7_9__(xxx, __addressof__(FooModule.$foo$closure$1))
        if len(node.Arguments) == 2:
            arg = node.Arguments[1]
            if arg.NodeType == NodeType.MethodInvocationExpression:
                method as MethodInvocationExpression = arg
                if '__addressof__' == method.Target.ToString():
                    arg = method.Arguments[0]
                    Write "/*CLOSURE: $arg*/"


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
        WriteIndented

        # Modifier needs to be first in JS
        Visit node.Modifier if node.Modifier

        Write 'return '
        Visit node.Expression
        Write ';'
        WriteLine

    def OnRaiseStatement(node as RaiseStatement):
        WriteIndented
        Write 'throw '
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
        parens = NeedsParensAround(node.Condition)
        WriteIndented 'if (! '
        Write '(' if parens
        Visit(node.Condition)
        Write ')' if parens 
        Write ') '

        WriteOpenBrace
        Visit(node.Block)
        WriteCloseBrace

    def OnBreakStatement(node as BreakStatement):
        WriteIndented 'break;'
        WriteLine

    def OnContinueStatement(node as ContinueStatement):
        WriteIndented 'continue;'
        WriteLine

    def OnUnaryExpression(node as UnaryExpression):
        Write '(' if NeedsParensAround(node)
        
        isPostOp = AstUtil.IsPostUnaryOperator(node.Operator)
        Write GetUnaryOperatorText(node.Operator) if not isPostOp
        Visit node.Operand
        Write GetUnaryOperatorText(node.Operator) if isPostOp

        Write ')' if NeedsParensAround(node)

    def GetUnaryOperatorText(op as UnaryOperatorType):
        if op == UnaryOperatorType.PostIncrement or op == UnaryOperatorType.Increment:
            return '++'
        elif op == UnaryOperatorType.PostDecrement or op == UnaryOperatorType.Decrement:
            return '--'
        elif op == UnaryOperatorType.UnaryNegation:
            return '-'
        elif op == UnaryOperatorType.LogicalNot:
            return '!'
        elif op == UnaryOperatorType.OnesComplement:
            return '~'
        elif op == UnaryOperatorType.Explode:
            raise 'Explode operator "*" is not supported'
        elif op == UnaryOperatorType.AddressOf:
            raise 'AddressOf operator "&" is not supported' 
        elif op == UnaryOperatorType.Indirection:
            raise 'Indirection operator "*" is not supported'
        else:
            raise 'Invalid operator "' + op + '"'

    def OnBinaryExpression(node as BinaryExpression):

        if node.Operator == BinaryOperatorType.Assign:
            Visit node.Left
            Write ' = '
            Visit node.Right
        elif node.Operator == BinaryOperatorType.Exponentiation:
            Write 'Math.pow('
            Visit node.Left
            Write ', '
            Visit node.Right
            Write ')'
        elif node.Operator == BinaryOperatorType.Match: # a =~ b
            # TODO: If we have a runtime we can match regexp too
            Write '(-1 !== '
            Visit node.Left
            Write '.indexOf('
            Visit node.Right
            Write '))'
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
        else:
            parens = NeedsParensAround(node)
            Write '(' if parens
            Visit node.Left
            Write " "
            Write GetBinaryOperatorText(node.Operator)
            Write " "
            if node.Operator == BinaryOperatorType.TypeTest:
                # isa rhs is encoded in a typeof expression
                Visit( (node.Right as TypeofExpression).Type )
            else: 
                Visit node.Right

            Write ')' if parens

    def GetBinaryOperatorText(op as BinaryOperatorType):

        return '=' if op == BinaryOperatorType.Assign
        # Note: We use equality in value and type in JS
        return '===' if op == BinaryOperatorType.Equality
        return '!==' if op == BinaryOperatorType.Inequality
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

        raise 'Operator $(op) is not implemented'

    def NeedsParensAround(node as Expression):
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

    def IsInterfaceMember(n as TypeMember):
        return n.ParentNode and n.ParentNode.NodeType == NodeType.InterfaceDefinition

    def WriteCallableDefinitionHeader(keyword as string, node as CallableDefinition):
        /*WriteAttributes(node.Attributes, true)*/
        /*WriteOptionalModifiers(node)*/

        # TODO: Inspect params and return to generate type annotations for Closure

        WriteIndented keyword

        em = node as IExplicitMember
        if em:
            Visit em.ExplicitInfo

        Write node.Name 
        if node.GenericParameters.Count > 0:
            Write('[of ')
            WriteCommaSeparatedList(node.GenericParameters)
            Write(']')

        WriteParameterList(node.Parameters, '(', ')')

        if node.ReturnTypeAttributes.Count > 0:
            Write ' '
            #WriteAttributes(node.ReturnTypeAttributes, false)


    def WriteParameterList(params as ParameterDeclarationCollection, st, ed):
        Write(st)
        i = 0
        for param in params:
            if i > 0:
                Write(', ')
            if param.IsParamArray:
                Write('*')
            Visit(param)
            i++
        Write(ed)

    def OnParameterDeclaration(p as ParameterDeclaration):
        /*WriteAttributes(p.Attributes, false)*/

        if p.IsByRef:
            Write "ref "

        if IsCallableTypeReferenceParameter(p):
            if p.IsParamArray: Write("*")
            Visit(p.Type);
        else:
            Write(p.Name);
            #WriteTypeReference(p.Type);


    def OnEnumDefinition(node as EnumDefinition):
        # TODO: Prefix with namespace
        Write "$(node.FullName) = "
        WriteOpenBrace
        for member as EnumMember in node.Members:
            if not member.Initializer:
                raise 'Enum definition without an initializer value!'

            WriteIndented
            Write member.Name
            Write ': '
            Visit member.Initializer
            WriteLine

        WriteCloseBrace

    def ___OnClassDefinition(node as ClassDefinition):
        Write "$(node.Name) = function()"
        WriteOpenBrace

        if len(node.BaseTypes):
            Write '/* extends '
            WriteCommaSeparatedList(node.BaseTypes)
            Write '*/'
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



    def OnField(f as Field):
        #WriteAttributes(f.Attributes, true);
        #WriteModifiers(f);

        if f.IsStatic:
            Write f.FullName
        else:
            Write f.Name
        #WriteTypeReference f.Type

        if f.Initializer:
            Write ' = '
            Visit f.Initializer
        else:
            Write ' = null;'
            
        WriteLine

    def OnConstructor(node as Constructor):
        OnMethod(node)


    def WriteTypeDefinition(keyword, node as TypeDefinition):
        raise 'This is not yet implemented'

        #WriteAttributes(node.Attributes, true)
        #WriteModifiers(node)
        WriteIndented 
        Write keyword
        Write ' '

        splice = node.ParentNode as SpliceTypeMember
        if splice:
            #WriteSplicedExpression(splice.NameExpression)
            pass
        else:
            Write(node.Name)

        #if len(node.GenericParameters):
        #    WriteGenericParameterList(node.GenericParameters);

        if len(node.BaseTypes):
            Write("(")
            WriteCommaSeparatedList(node.BaseTypes)
            Write(")")

        WriteLine(":")
        if len(node.Members):
            for member as TypeMember in node.Members:
                print member.NodeType
                Visit(member)
                WriteLine()
        else:
            Write 'pass'

    def OnExpressionPair(pair as ExpressionPair):
        print pair
        Visit(pair.First)
        Write(": ")
        Visit(pair.Second)

    def IsCallableTypeReferenceParameter(p as ParameterDeclaration):
        parent = p.ParentNode
        return parent and parent.NodeType == NodeType.CallableTypeReference

    def WriteAttribute(attribute as Attribute, prefix as string):
        WriteIndented("[")
        Write(prefix) if prefix
        Write(attribute.Name)
        if attribute.Arguments.Count > 0 or attribute.NamedArguments.Count > 0:
            Write("(")
            WriteCommaSeparatedList(attribute.Arguments)
            if attribute.NamedArguments.Count > 0:
                if attribute.Arguments.Count > 0:
                    Write(", ")
                WriteCommaSeparatedList(attribute.NamedArguments)
            Write(")")
        Write("]")

    def WriteStringLiteral(text as string):
        WriteStringLiteral text, "'"

    def WriteStringLiteral(text as string, quote as string):
        Write quote
        WriteStringContent text, quote
        Write quote

    def WriteStringContent(text as string, quote as string):
        for ch in text:
            if ch == '\r':
                Write '\\r'
            elif ch == '\n':
                Write '\\n'
            elif ch == '\t':
                Write '\\t'
            elif ch == '\0':
                Write '\\0'
            elif ch == '\\':
                Write '\\\\'
            elif ch == "'" and ch == quote:
                Write "\\'"
            elif ch == '"' and ch == quote:
                Write '\\"'
            else:
                Write(ch.ToString())




class PrintJs(PrintBoo):

    override def Run():
        visitor = JsPrinterVisitor(OutputWriter)
        visitor.Initialize(Context)
        visitor.Print(CompileUnit);


