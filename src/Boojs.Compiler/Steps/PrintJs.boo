namespace Boojs.Compiler.Steps

import Boo.Lang.Compiler.Steps
import Boo.Lang.Compiler.Ast
import Boo.Lang.Compiler.TypeSystem
import Boo.Lang.Compiler.TypeSystem.Services

#class JsPrinterVisitor(Visitors.BooPrinterVisitor):
class JsPrinterVisitor(Visitors.TextEmitter):

    # TODO: Comments are not present in the AST?

    def constructor(writer as System.IO.TextWriter):
        super(writer)

    override def OnBoolLiteralExpression(node as BoolLiteralExpression):
        if node.Value:
            WriteKeyword('TRUE')
        else:
            WriteKeyword('FALSE')

    def OnModule(node as Module):
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

    def OnMethod(m as Method):
        if m.IsRuntime:
            WriteIndented('// runtime')
            WriteLine()

        WriteCallableDefinitionHeader('function ', m)
        if IsInterfaceMember(m):
            WriteLine()
        else:
            OpenBrace
            Visit m.Locals
            WriteLine
            Visit m.Body
            CloseBrace

    def OpenBrace():
        Write '{'
        WriteLine
        Indent

    def CloseBrace(cr):
        Dedent
        WriteIndented
        Write '}'
        WriteLine if cr
    
    def CloseBrace():
        CloseBrace(true)


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

    def OnDeclarationStatement(node as DeclarationStatement):
        # TODO: Not used?
        Visit node.Declaration
        if node.Initializer:
            WriteOperator ' = '
            Visit node.Initializer
        Write '; // OnDeclarationStatement'
        WriteLine

    def OnDeclaration(node as Declaration):
        # TODO: Not used?
        WriteIndented('var {0}; // OnDeclaration', node.Name)


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
            CloseBrace false
            WriteIfBlock(' else if', stmt)
            block = stmt.FalseBlock

        if block:
            CloseBrace false
            WriteIndented ' else '
            OpenBrace
            Visit block.Statements

        CloseBrace

    def WriteIfBlock(keyword, node as IfStatement):
        Write keyword + ' ('
        Visit node.Condition
        Write ') '
        OpenBrace
        Visit(node.TrueBlock.Statements)

    def OnConditionalExpression(node as ConditionalExpression):
    """ Convert to the ternary operator.
            a = (10 if true else 20)  -->  a = true ? 10 : 20
    """
        # TODO: Omit parens if the expression is simple
        Write '('
        Visit node.Condition
        Write ') ? ('
        Visit node.TrueValue
        Write ') : ('
        Visit node.FalseValue
        Write ')'

    def OnArrayLiteralExpression(node as ArrayLiteralExpression):
    """ Arrays in Boo are immutable but we convert them to plain JS arrays
    """ 
        WriteDelimitedCommaSeparatedList('[', node.Items, ']')

    def WriteDelimitedCommaSeparatedList(opening, list as Expression*, closing):
        Write(opening)
        WriteCommaSeparatedList(list)
        Write(closing)

    def OnSelfLiteralExpression(node as SelfLiteralExpression):
        WriteKeyword 'this'

    def OnCharLiteralExpression(node as CharLiteralExpression):
    """ Chars in JS are strings of length 1 """
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
        # TODO: A possible optimization is to build a literal array to fill the parts
        #       and join it at the end -> [ 'one', foo, 'bar' ].join('')

        # TODO: It seems that Boojay replaces the interpolation in one of the compiler steps

        Write '"'
        for arg in node.Expressions:
            if arg.NodeType == NodeType.StringLiteralExpression:
                # TODO: What's this? a simple string?
                /*WriteStringLiteralContents((arg as StringLiteralExpression).Value, _writer, false)*/
                pass
            elif arg.NodeType == NodeType.ReferenceExpression or arg.NodeType == NodeType.BinaryExpression:
                Write '" + '
                Visit(arg)
                Write ' + "'
            else:
                Write '" + ('
                Visit(arg)
                Write ') + "'

        Write '"'

    def OnReturnStatement(node as ReturnStatement):
        WriteIndented

        # Modifier needs to be first in JS
        Visit node.Modifier if node.Modifier

        WriteKeyword 'return '
        Visit node.Expression
        Write ';'
        WriteLine


    def OnStatementModifier(node as StatementModifier):
        raise 'Statement modifiers should be handled by NormalizeStatementModifiers compiler step'

    def OnLabelStatement(node as LabelStatement):
        raise 'Labels is not implemented in Boojs'

    def OnGotoStatement(node as GotoStatement):
        raise 'Goto is not implemented in Boojs'

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

        # TODO: Generate unique names for variables

        WriteIndented 
        Write 'var __ref = '
        Visit node.Iterator
        Write ';'
        WriteLine

        WriteIndented
        WriteKeyword 'for (var '

        if node.Declarations.Count == 1:
            Write "__i=0, __l=__ref.length; __i<__l; i++) "
            OpenBrace
            WriteIndented '{0} = __ref[__i];', node.Declarations[0].Name
            WriteLine
        elif node.Declarations.Count == 2:
            Write "$(node.Declarations[1].Name), $(node.Declarations[0].Name) in __ref) "
            OpenBrace
            WriteIndented '{0} = __ref[{1}];', node.Declarations[1].Name, node.Declarations[0].Name
            WriteLine
        else:
            raise 'Unexpected number of declarations in for loop'

        WriteBlock node.Block

        CloseBrace

        if node.OrBlock:
            raise '"or:" blocks in for loops are not supported yet'
            
        if node.ThenBlock:
            raise '"then:" blocks in for loops are not supported yet'


    def OnUnlessStatement(node as UnlessStatement):
        WriteIndented 'if (!('
        Visit(node.Condition)
        Write ')) '
        OpenBrace
        Visit(node.Block)
        CloseBrace

    def OnUnaryExpression(node as UnaryExpression):
        # TODO: Remove parens if not needed
        Write '('
        
        isPostOp = AstUtil.IsPostUnaryOperator(node.Operator)
        if not isPostOp:
            WriteOperator GetUnaryOperatorText(node.Operator)
        
        Visit node.Operand
        if isPostOp:
            WriteOperator GetUnaryOperatorText(node.Operator)

        Write ')'

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
        if node.Operator == BinaryOperatorType.Exponentiation:
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
        else:
            # TODO: Remove parens if not needed
            Write '('
            Visit node.Left
            Write " "
            WriteOperator GetBinaryOperatorText(node.Operator)
            Write " "
            if node.Operator == BinaryOperatorType.TypeTest:
                # isa rhs is encoded in a typeof expression
                Visit( (node.Right as TypeofExpression).Type )
            else: 
                Visit node.Right

            Write ')'

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
        return '!in' if op == BinaryOperatorType.NotMember

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


    def IsInterfaceMember(n as TypeMember):
        return n.ParentNode and n.ParentNode.NodeType == NodeType.InterfaceDefinition

    def WriteCallableDefinitionHeader(keyword as string, node as CallableDefinition):
        /*WriteAttributes(node.Attributes, true)*/
        /*WriteOptionalModifiers(node)*/

        if node.ReturnType:
            WriteIndented '/**'
            WriteLine
            # TODO: Inspect params to generate type annotations for Closure
            if node.ReturnType:
                WriteIndented 
                Write ' * @return {'
                Visit node.ReturnType
                Write '}'
                WriteLine
            WriteIndented ' */'
            WriteLine

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
            WriteKeyword("ref ")

        if IsCallableTypeReferenceParameter(p):
            if p.IsParamArray: Write("*")
            Visit(p.Type);
        else:
            Write(p.Name);
            #WriteTypeReference(p.Type);

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

    def _OnMethodInvocationExpression(node as MethodInvocationExpression):
        WriteIndented('MethodInvocation')
        WriteLine()



class PrintJs(PrintBoo):

    override def Run():
        visitor = JsPrinterVisitor(OutputWriter)
        visitor.Print(CompileUnit);


