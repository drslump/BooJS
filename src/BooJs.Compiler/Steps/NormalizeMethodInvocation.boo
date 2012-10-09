namespace BooJs.Compiler.Steps

import Boo.Lang.Compiler
import Boo.Lang.Compiler.Ast
import Boo.Lang.Compiler.Steps

import Boo.Lang.Environments
import Boo.Lang.Compiler.TypeSystem.Services.RuntimeMethodCache as BooRuntimeMethodCache
import BooJs.Compiler.TypeSystem(RuntimeMethodCache)


class NormalizeMethodInvocation(AbstractTransformerCompilerStep):
"""
    Normalize method invocations to undo some of the instrumentation performend byte Boo's ProcessMethodBodies step.
    Since Javascript is highly dynamic there is no need to call special interface methods for things like array access
    or calling anonymous functions.
"""
    [getter(MethodCache)]
    private _methodCache as RuntimeMethodCache

    [getter(BooMethodCache)]
    private _booMethodCache as BooRuntimeMethodCache

    def Initialize(context as CompilerContext):
        super(context)

        _methodCache = EnvironmentProvision[of RuntimeMethodCache]()
        _booMethodCache = EnvironmentProvision[of BooRuntimeMethodCache]()

    def LeaveMethodInvocationExpression(node as MethodInvocationExpression):
    """ We need to attach to the Leave hook since we sometimes have to replace the node """

        # Map runtime methods inserted by Boo to our custom ones
        target = node.Target
        if target isa ReferenceExpression:
            # Handle equality
            if target.Entity is BooMethodCache.RuntimeServices_EqualityOperator:
                mie = CodeBuilder.CreateMethodInvocation(MethodCache.RuntimeEquality, node.Arguments[0], node.Arguments[1])
                ReplaceCurrentNode mie
                return
            # Handle enumerables
            elif target.Entity is BooMethodCache.RuntimeServices_GetEnumerable:
                mie = CodeBuilder.CreateMethodInvocation(MethodCache.RuntimeEnumerable, node.Arguments[0])
                ReplaceCurrentNode mie
                return
            # Removes ICallable `.Call`
            elif target.Entity is BooMethodCache.ICallable_Call:
                t_target = (target as MemberReferenceExpression).Target
                node.Target = t_target
                return

            # Retarget builtins
            elif target.Entity and TypeSystemServices.IsBuiltin(target.Entity):
                if target.NodeType == NodeType.MemberReferenceExpression:
                    (target as MemberReferenceExpression).Target = [| Boo |]
                else:
                    (target as ReferenceExpression).Name = 'Boo.' + (target as ReferenceExpression).Name
                return

        /*
        if node.Target isa MemberReferenceExpression:
            NormalizeTarget(node, node.Target as MemberReferenceExpression)
        elif node.Target isa ReferenceExpression:
            NormalizeTarget(node, node.Target as ReferenceExpression)
        */

        /*
        # Revert: CompilerGenerated.__FooModule_foo$callable0$7_9__(xxx, __addressof__(FooModule.$foo$closure$1))
        if len(node.Arguments) == 2:
            arg = node.Arguments[1]
            if arg.NodeType == NodeType.MethodInvocationExpression:
                method as MethodInvocationExpression = arg
                if '__addressof__' == method.Target.Name:
                    arg = method.Arguments[0]
                    Write "/ *CLOSURE: $arg* /"
        */

    private def NormalizeTarget(node as MethodInvocationExpression, target as MemberReferenceExpression):
        # Convert: Boo.Lang.RuntimeServices.xxx -> Boo.xxx
        if false and target.Target.ToString() == 'Boo.Lang.Runtime.RuntimeServices':
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
        # TODO: Use proper detection via types
        elif target.Target.ToString() == 'BooJs.Lang.Builtins':
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
        if target.Name == '__initobj__':
            if len(node.Arguments) > 1:
                ReplaceCurrentNode([| $(node.Arguments[0]) = $(node.Arguments[1]) |])
            else:
                block = node.ParentNode.ParentNode as Block
                block.Statements.Remove(node.ParentNode)

        # Some methods are defined as simple ReferenceExpressions instead of MemberReferenceExpression chains
        # Conversion: Boo.Lang.Runtime.RuntimeServices.xxx -> Boo.xxx
        elif target.Name =~ /^Boo\.Lang\.Runtime\.RuntimeServices\./:
            #target.Name = 'Boo.Lang.' + target.Name[len('Boo.Lang.Runtime.RuntimeServices.'):]
            pass

        elif target.Name =~ /^BooJs\.Lang\./:
            #target.Name = 'Boo.Lang.' + target.Name[len('BooJs.Lang.'):]
            pass

        else:
            # Some primitive types are not expanded so we need to check if we are handling a primitive
            # type to replace it with the actual type defined ( string -> BooJs.Lang.String )
            parts = target.Name.Split(char('.'))
            if false and TypeSystemServices.IsPrimitive(parts[0]):
                type = TypeSystemServices.ResolvePrimitive(parts[0])
                if type isa TypeSystem.Reflection.ExternalType:
                    parts[0] = (type as TypeSystem.Reflection.ExternalType).ActualType.FullName
                    target.Name = join(parts, '.')
                    # Execute again once we have replace the type name
                    NormalizeTarget(node, target)

