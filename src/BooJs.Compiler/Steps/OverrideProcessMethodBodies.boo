namespace BooJs.Compiler.Steps

import Boo.Lang.Compiler.Steps
import Boo.Lang.Compiler.Ast
import Boo.Lang.Compiler.TypeSystem

import Boo.Lang.Environments

class OverrideProcessMethodBodies(ProcessMethodBodiesWithDuckTyping):
""" Overrides some methods of the step to skip some modification made originally
"""

    class Pmb(IQuackFu):
    """ Uses reflection to call private methods in the ancestor class ProcessMethodBodies via a
        IQuackFu api.
    """
        pmb = typeof(ProcessMethodBodies)
        instance as ProcessMethodBodies
        def constructor(instance):
            self.instance = instance

        def QuackGet(prop as string, args as (object)):
            pass
        def QuackSet(prop as string, args as (object), val as object):
            pass
        def QuackInvoke(method as string, params as (object)) as object:
            types = array(System.Type, param.GetType() for param in params)
            mi = pmb.GetMethod(method, BindingFlags.InvokeMethod | BindingFlags.NonPublic | BindingFlags.Instance,
                               null, types, null)
            if not mi:
                raise 'Private method {0} not found' % method
            return mi.Invoke(instance, params)

    # Obtain an instance to call ProcessMethodBodies private methods
    pmb = Pmb(self)


    override def Initialize(context as Boo.Lang.Compiler.CompilerContext):
        super(context)

    override def LeaveUnaryExpression(node as UnaryExpression):
        # Increment/Decrement operators are resolved using a fairly complex eval. Since
        # JS supports this operators natively we can simplify the case by just binding
        # the correct type to the expression.
        if node.Operator in (UnaryOperatorType.Increment, UnaryOperatorType.Decrement,
                             UnaryOperatorType.PostDecrement, UnaryOperatorType.PostIncrement):
            # TODO: This doesn't take into account any operator overloading logic

            # Bind the type of the operand to the operation
            node.ExpressionType = GetExpressionType(node.Operand)
            return

        # Fall back to the original logic
        super(node)

    override def ProcessBuiltinInvocation(node as MethodInvocationExpression, func as BuiltinFunction):
        # Replace len(val) with val.length
        if func.FunctionType == BuiltinFunctionType.Len:
            target = node.Arguments[0]
            result = MemberReferenceExpression(node.LexicalInfo, target, 'length')
            result.ExpressionType = TypeSystemServices.IntType

            node.ParentNode.Replace(node, result)
            return

        super(node, func)

    override def LeaveDeclarationStatement(node as DeclarationStatement):
        # If the declaration has been annotated as global via the `global` macro
        # we must avoid generating a declaration for it, either removing it
        # or just setting a value to it if the used supplied an initializer
        decl = node.Declaration
        if decl.ContainsAnnotation('global'):
            if not decl.Type:
                decl.Type = CodeBuilder.CreateTypeReference(decl.LexicalInfo, TypeSystemServices.DuckType)

            type = GetType(decl.Type)
            entity as Internal.InternalLocal = DeclareLocal(node, decl.Name, type, false)
            entity.OriginalDeclaration = decl

            if node.Initializer:
                node.ReplaceBy(
                    ExpressionStatement(
                        CodeBuilder.CreateAssignment(
                            node.LexicalInfo,
                            CodeBuilder.CreateReference(entity),
                            node.Initializer)
                        )
                    )
            else:
                (node.ParentNode as Block).Statements.Remove(node)

            return

        super(node)

    override protected def BindBinaryExpression(node as BinaryExpression):
        # Boo would directly allow all arithmetic on number types. We have to
        # specifically process those that are not valid in javascript

        ltype = GetExpressionType(node.Left)
        rtype = GetExpressionType(node.Right)

        if node.Operator == BinaryOperatorType.Exponentiation:
            #pmb.BindNullableOperation(node)
            if not pmb.ResolveOperator(node):
                pmb.InvalidOperatorForTypes(node)
        elif node.Operator == BinaryOperatorType.Division and \
             TypeSystemServices.IsIntegerNumber(ltype) and \
             TypeSystemServices.IsIntegerNumber(rtype):

             #pmb.BindNullableOperator(node)
             if not pmb.ResolveOperator(node):
                pmb.InvalidOperatorForTypes(node)
        else:
            super(node)

