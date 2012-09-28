namespace BooJs.Compiler.Steps

import Boo.Lang.Compiler.Steps
import Boo.Lang.Compiler.Ast
import Boo.Lang.Compiler.TypeSystem

class OverrideProcessMethodBodies(ProcessMethodBodiesWithDuckTyping):
""" Overrides some methods of the step to skip some modification made originally
"""

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
            #result.Entity = TypeSystemServices.IntType
            result.ExpressionType = TypeSystemServices.IntType

            node.ParentNode.Replace(node, result)
            return

        super(node, func)


    override def BindBinaryExpression(node as BinaryExpression):
        # TODO: Improve this!
        #if node.Operator == BinaryOperatorType.Addition:
        #    if GetExpressionType(node.Left) == GetExpressionType(node.Right):
        #        return

        super(node)

    override protected def CreateDefaultLocalInitializer(node as Node, local as IEntity) as Expression:
        if local isa Internal.InternalLocal:
            type as Reflection.ExternalType = (local as Internal.InternalLocal).Type
            if type.ActualType == BooJs.Lang.Global:
                # TODO: Refactor this to avoid inserting the expression
                return [| __global_initializer_should_be_removed__ = null |]

        return super(node, local)

    override def LeaveSlicingExpression(node as SlicingExpression):
        # Slicing over lists gets transformed to a method call
        print 'SLICING A:', node, node.NodeType

        super(node)

        #if node.Target isa MemberReferenceExpression:
        #    target = node.Target as MemberReferenceExpression
        #    if target.Name == 'Item':
        #        node.Target = target.Target

        print 'SLICING B:', node, node.NodeType

