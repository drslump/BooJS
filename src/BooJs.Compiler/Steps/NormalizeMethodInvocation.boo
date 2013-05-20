namespace BooJs.Compiler.Steps

import Boo.Lang.Compiler
import Boo.Lang.Compiler.Ast
import Boo.Lang.Compiler.Steps

import Boo.Lang.Environments
import Boo.Lang.Compiler.TypeSystem.Services.RuntimeMethodCache as BooRuntimeMethodCache
import BooJs.Compiler.TypeSystem(RuntimeMethodCache)


class NormalizeMethodInvocation(AbstractTransformerCompilerStep):
"""
    Normalize method invocations to undo some of the instrumentation performend by Boo's 
    ProcessMethodBodies step. Since Javascript is highly dynamic there is no need to call 
    special interface methods for things like array access or calling anonymous functions.
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
                # Convert varargs to plain arguments
                # TODO: What happens if the callable actually expects a vararg?
                if len(node.Arguments) == 1 and node.Arguments.First.NodeType == NodeType.ArrayLiteralExpression:
                    lst = (node.Arguments.First as ArrayLiteralExpression).Items
                    node.Arguments.Clear()
                    for arg in lst:
                        node.Arguments.Add(arg)
                return
            # Retarget builtins
            elif target.Entity and TypeSystemServices.IsBuiltin(target.Entity):
                if target.NodeType == NodeType.MemberReferenceExpression:
                    (target as MemberReferenceExpression).Target = [| Boo |]
                else:
                    (target as ReferenceExpression).Name = 'Boo.' + (target as ReferenceExpression).Name
                return

