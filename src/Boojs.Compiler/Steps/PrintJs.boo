namespace Boojs.Compiler.Steps

import Boo.Lang.Compiler.Steps
import Boo.Lang.Compiler.Ast
import Boo.Lang.Compiler


class JsPrinterVisitor(Visitors.TextEmitter):

    # TODO: Comments are not present in the AST?

    _context as CompilerContext


    def constructor(writer as System.IO.TextWriter):
        # We need to override the constructor otherwise Boo complains
        super(writer)
        IndentText = '  '

    def Print(ast as CompileUnit):
        OnCompileUnit(ast)

    def OnBoolLiteralExpression(node as BoolLiteralExpression):
        if node.Value:
            Write 'true'
        else:
            Write 'false'

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


        # Wrap everything in a function to avoid leaking variables
        Write '(function(){'
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

        Write '}).call(this);'

    def OnMethod(m as Method):
        if m.IsRuntime:
            WriteIndented('// runtime')
            WriteLine()

        # HACK: If we detect the Main method we just output its statements
        if m.Name == 'Main':
            Visit m.Locals
            Visit m.Body
            return

        WriteCallableDefinitionHeader('function ', m)
        if IsInterfaceMember(m):
            WriteLine()
        else:
            WriteOpenBrace
            Visit m.Locals
            WriteLine
            Visit m.Body
            WriteCloseBrace

    def OnBlockExpression(node as BlockExpression):
    """ Javascript has native support for closures thus the conversion is very simple.
    """
        Write 'function('
        if len(node.Parameters):
            WriteCommaSeparatedList(node.Parameters)
        Write ')'
        if node.Body.IsEmpty:
            Write '{}'
        else:
            # TODO: When it's just one statement we should inject a return if not present
            WriteOpenBrace
            Visit(node.Body.Statements)
            WriteCloseBrace false

    def WriteOpenBrace():
        Write '{'
        WriteLine
        Indent
        WriteIndented

    def WriteCloseBrace(cr):
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
        if ilocal.Type.ToString() == 'Boojs.Lang.global':
            return

        # TODO: Add type annotations
        WriteIndented
        Write 'var ' + node.Name + '; // OnLocal'
        WriteLine

    def Initialize(context as CompilerContext):
        _context = context

    def OnReferenceExpression(node as ReferenceExpression):
        # TODO: Check name for invalid chars?
        Write(node.Name)

    def OnDeclarationStatement(node as DeclarationStatement):
        # TODO: Not used?
        Visit node.Declaration
        if node.Initializer:
            Write ' = '
            Visit node.Initializer
        Write '; /*OnDeclarationStatement*/'
        WriteLine

    def OnDeclaration(node as Declaration):
        # TODO: Not used?
        WriteIndented "var $(node.Name) /*OnDeclaration*/"


    def OnIfStatement(node as IfStatement):
        WriteIndented
        WriteIfBlock('if', node)

        def IsElIf(block as Block):
            return false if not block
            return false if block.Statements.Count != 1
            return block.Statements[0] isa IfStatement

        block = node.FalseBlock
        while IsElIf(block):
            stmt as IfStatement = block.Statements[0]
            WriteCloseBrace false
            WriteIfBlock(' else if', stmt)
            block = stmt.FalseBlock

        if block:
            WriteCloseBrace false
            WriteIndented ' else '
            WriteOpenBrace
            Visit block.Statements

        WriteCloseBrace

    def WriteIfBlock(keyword, node as IfStatement):
        Write keyword + ' ('
        Visit node.Condition
        Write ') '
        WriteOpenBrace
        Visit(node.TrueBlock.Statements)

    def OnConditionalExpression(node as ConditionalExpression):
    """ Convert to the ternary operator.
            a = (10 if true else 20)  -->  a = true ? 10 : 20
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
    """ Arrays in Boo are immutable but we convert them to plain JS arrays
    """ 
        WriteDelimitedCommaSeparatedList('[', node.Items, ']')

    def WriteDelimitedCommaSeparatedList(opening, list as Expression*, closing):
        Write(opening)
        WriteCommaSeparatedList(list)
        Write(closing)

    def OnSelfLiteralExpression(node as SelfLiteralExpression):
        Write 'this'

    def OnCharLiteralExpression(node as CharLiteralExpression):
    """ Chars in JS are strings of length 1 """
        WriteStringLiteral(node.Value)

    def OnStringLiteralExpression(node as StringLiteralExpression):
        WriteStringLiteral(node.Value)

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
    """ We build a literal array and then join it to form the string

            "foo \$bar" -> ['foo', bar].join('')
    """
        Write '['
        first = true
        for arg in node.Expressions:
            if arg.NodeType == NodeType.StringLiteralExpression:
                value = (arg as StringLiteralExpression).Value
                if value:
                    Write ', ' if not first
                    WriteStringLiteral((arg as StringLiteralExpression).Value)
            else:
                Write ', ' if not first
                Visit(arg)

            first = false

        Write "].join('')"

    def OnMemberReferenceExpression(node as MemberReferenceExpression):
        # TODO: Check if the property name is a valid javascript ident and if not use ['xxx'] syntax
        Visit node.Target
        Write '.'
        Write node.Name

    def UndoOperatorInvocation(node as MethodInvocationExpression, operator as BinaryOperatorType):
        expr = BinaryExpression(node.LexicalInfo)
        expr.Operator = operator
        expr.Left = node.Arguments[0]
        expr.Right = node.Arguments[1]
        Visit expr

    def OnMethodInvocationExpression(node as MethodInvocationExpression):

        # HACK: Boo converts the equality comparison to a runtime call for those atoms
        #       without an static type on the complex ProcessMethodBodies step.
        #       Instead of changing that step we undo the transformation since it's
        #       much simple although very dirty :(
        # TODO: Although we keep this hack it should be moved to its own dedicated step
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
        Visit(node.Exception);
        WriteLine

    def OnStructDefinition(node as StructDefinition):
    """ Boo's struct a value type like strings or integers that works as a class. It means 
        that when declaring it an instance is created and when passing it to a function a 
        copy is made instead of passing a reference.
        Javascript doesn't have any similar type so the conversion is not trivial. Perhaps
        we can have a 'clone' method in the runtime which gets used when we detect a struct 
        type.
    """
        raise 'Struct is not implemented in Boojs'

    def OnStatementModifier(node as StatementModifier):
        raise 'Statement modifiers should be handled by NormalizeStatementModifiers compiler step'

    def OnLabelStatement(node as LabelStatement):
        raise 'Label is not implemented in Boojs'

    def OnGotoStatement(node as GotoStatement):
        raise 'Goto is not implemented in Boojs'

    def OnMacroStatement(node as MacroStatement):
        raise 'Macro is not implemented in Boojs'

    def OnYieldStatement(node as YieldStatement):
    """ Porting yield/generators to standard Javascript is very difficult and it's not
        clear that it could work in all cases. Only Firefox supports them natively thus
        one option could be to add a compiler flag to allow them.
    """
        raise 'Yield is not implemented in Boojs'

    def OnEvent(node as Event):
    """ Boo Event's are a way to easily setup delegates in classes, implementing the 
        observer pattern. Basically they allow registering a callback on them from outside
        the class but only firing them from inside the class.
        There is no clear translation of them to Javascript, we could perhaps just implement
        them using a runtime.
    """
        raise 'Event is not implemented in Boojs'


    def OnForStatement(node as ForStatement):
    """ Boo's for statement does not allow to specify a receiving variable for the key like it's 
        done in CoffeeScript (for v,k in hash), however the parser defines the receiving variables
        as a multiple token, thus it's in theory posible to implement CoffeeScript behaviour.

        The current implementation is very naive, it won't inspect the type system to 
        choose a proper loop strategy. This should be done in the future using a compiler
        step.

        Since arrays and hashmaps are iterated differently in JS but we only have an iteration
        keyword in Boo, the following logic takes place to allow both styles of iteration:

          for v in foo          ->      for (var _i=0, _l=foo.length; _i<_l; i++) { 
                                            v = foo[_i]

          for k,v in foo        ->      for (var k in foo) {
                                            v = foo[k]

        The future strategy will probably be to check the type of the iterator expression
        and if it's 'natively' iterable it will resort to a runtime function which can
        add support for generators.
    """

        # TODO: Optimize range() iterations

        refvar = _context.GetUniqueName('ref')
        WriteIndented 'var {0} = ', refvar
        Visit node.Iterator
        Write ';'
        WriteLine

        if len(node.Declarations) == 1:
            idxvar = _context.GetUniqueName('i')
            lenvar = _context.GetUniqueName('len')
            WriteIndented "for (var $idxvar=0, $lenvar=$refvar.length; $idxvar<$lenvar; $idxvar++) "
            WriteOpenBrace
            Write "$(node.Declarations[0].Name) = $refvar[$idxvar];"
            WriteLine
        elif node.Declarations.Count == 2:
            WriteIndented "for ({0} in {1}) ", node.Declarations[0].Name, refvar
            WriteOpenBrace
            Write "$(node.Declarations[1].Name) = $refvar[$(node.Declarations[0].Name)];"
            WriteLine
        else:
            raise 'Unexpected number of declarations in for loop'

        Visit node.Block

        WriteCloseBrace

        if node.OrBlock:
            raise '"or:" blocks in for loops are not supported yet'
            
        if node.ThenBlock:
            raise '"then:" blocks in for loops are not supported yet'


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
        Write "$(node.Name) = "
        WriteOpenBrace
        for member as EnumMember in node.Members:
            if not member.Initializer:
                raise 'Enum definition without an initializer value is not supported!'

            WriteIndented
            Write member.Name
            Write ': '
            Visit member.Initializer
            WriteLine

        WriteCloseBrace

    def OnClassDefinition(node as ClassDefinition):
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


