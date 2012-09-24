namespace BooJs.Compiler.Steps

import Boo.Lang.Compiler
import Boo.Lang.Compiler.Ast
import Boo.Lang.Compiler.Steps

class NormalizeMethodInvocation(AbstractTransformerCompilerStep):
"""
    Normalize method invocations to undo some of the instrumentation performend byte Boo's ProcessMethodBodies step.
    Since Javascript is highly dynamic there is no need to call special interface methods for things like array access
    or calling anonymous functions.
"""

    def LeaveMethodInvocationExpression(node as MethodInvocationExpression):
    """ We need to attach to the Leave hook since we sometimes have to replace the node """

        if node.Target isa MemberReferenceExpression:
            NormalizeTarget(node, node.Target as MemberReferenceExpression)
        elif node.Target isa ReferenceExpression:
            NormalizeTarget(node, node.Target as ReferenceExpression)

        /*
        # Revert: CompilerGenerated.__FooModule_foo$callable0$7_9__(xxx, __addressof__(FooModule.$foo$closure$1))
        if len(node.Arguments) == 2:
            arg = node.Arguments[1]
            if arg.NodeType == NodeType.MethodInvocationExpression:
                method as MethodInvocationExpression = arg
                if '__addressof__' == method.Target.Name:
                    arg = method.Arguments[0]
                    Write "/*CLOSURE: $arg*/"
        */

    private def UndoOperatorInvocation(node as MethodInvocationExpression, operator as BinaryOperatorType):
        expr = BinaryExpression(node.LexicalInfo)
        expr.Operator = operator
        expr.Left = node.Arguments[0]
        expr.Right = node.Arguments[1]
        Visit expr

    private def NormalizeTarget(node as MethodInvocationExpression, target as MemberReferenceExpression):
        # Convert: Boo.Lang.RuntimeServices.xxx -> Boo.xxx
        if target.Target.ToString() == 'Boo.Lang.Runtime.RuntimeServices':
            name = target.Name

            if name == 'EqualityOperator':
                target.Target = [| Boo.Lang |]
                target.Name = 'op_Equality'

            elif name == 'GetEnumerable':
                #ReplaceCurrentNode node.Arguments[0]
                target.Target = [| Boo.Lang |]
                target.Name = 'enumerable'

            elif name == 'GetRange1':
                # HACK: This call has been only found in compiler generated support code
                ReplaceCurrentNode [| $(node.Arguments[0]).slice( $(node.Arguments[1]) ) |]

            else:
                # For any other runtime service method we assume it has been implemented in the runtime
                target.Target = [| Boo.Lang |]

        # Process BooJs builtins (BooJs.Lang.BuiltinsModule.xxx -> Boo.xxx)
        elif target.Target.ToString() == 'BooJs.Lang.BuiltinsModule':
            target.Target = [| Boo |]

        # Convert: closure.Invoke() -> closure()
        elif target.Name == 'Invoke' and target.ExpressionType isa TypeSystem.Core.AnonymousCallableType:
            node.Target = target.Target

        # Convert: closure.Call() -> closure()
        elif target.Name == 'Call' and target.ExpressionType isa TypeSystem.Core.AnonymousCallableType:
            # Here the arguments are passed in as a list. We undo this to pass them normally.
            node.Target = target.Target
            for arg in (node.Arguments[0] as ArrayLiteralExpression).Items:
                node.Arguments.Add(arg)
            node.Arguments.RemoveAt(0)

        # Convert: value.get_Item(x) -> value[x]
        elif target.Name == 'get_Item':
            ReplaceCurrentNode( [| $(target.Target)[ $(node.Arguments[0]) ] |] )

        # Convert: value.set_Item(x, v) -> value[x] = v
        elif target.Name == 'set_Item':
            ReplaceCurrentNode( [| $(target.Target)[ $(node.Arguments[0]) ] = $(node.Arguments[1]) |] )


    private def NormalizeTarget(node as MethodInvocationExpression, target as ReferenceExpression):
        # Replace the initilization of a reference with a simple assignment
        if target.Name == '__initobj__' and len(node.Arguments) > 1:
            ReplaceCurrentNode([| $(node.Arguments[0]) = $(node.Arguments[1]) |])

        # Some methods are defined as simple ReferenceExpressions instead of MemberReferenceExpression chains
        # Conversion: Boo.Lang.Runtime.RuntimeServices.xxx -> Boo.xxx
        elif target.Name =~ /^Boo\.Lang\.Runtime\.RuntimeServices\./:
            target.Name = 'Boo.Lang.' + target.Name[len('Boo.Lang.Runtime.RuntimeServices.'):]

        elif target.Name =~ /^BooJs\.Lang\./:
            target.Name = 'Boo.Lang.' + target.Name[len('BooJs.Lang.'):]

