namespace BooJs.Compiler.Steps

from Boo.Lang.Compiler import CompilerContext
from Boo.Lang.Compiler.Ast import *
from Boo.Lang.Compiler.Steps import AbstractTransformerCompilerStep

from Boo.Lang.PatternMatching import *
from Boo.Lang.Environments import EnvironmentProvision
from Boo.Lang.Compiler.TypeSystem.Services import RuntimeMethodCache as BooRuntimeMethodCache
from Boo.Lang.Compiler.TypeSystem.Internal import InternalMethod, InternalField
from Boo.Lang.Compiler.TypeSystem import IMethod
from BooJs.Compiler.TypeSystem import RuntimeMethodCache


class NormalizeMethodInvocation(AbstractTransformerCompilerStep):
"""
    Normalize method invocations to undo some of the instrumentation performed by Boo's
    ProcessMethodBodies step. Since Javascript is highly dynamic there is no need to call
    special interface methods for things like array access or calling anonymous functions.

    NOTE: Events are converted here to use the runtime instead of the compiler generated
          methods introduced in BindTypeMembers. The solution is a bit dirty but it allows
          the standard Boo type resolution to work without modifications and then just undo
          the instrumentation.
    TODO: Move Events transformations to their own step
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
        target = node.Target as ReferenceExpression
        return unless target

        match target.Entity:
            # Handle equality
            case BooMethodCache.RuntimeServices_EqualityOperator:
                mie = CodeBuilder.CreateMethodInvocation(MethodCache.RuntimeEquality, node.Arguments[0], node.Arguments[1])
                ReplaceCurrentNode mie
            # Handle enumerables
            case BooMethodCache.RuntimeServices_GetEnumerable:
                mie = CodeBuilder.CreateMethodInvocation(MethodCache.RuntimeEnumerable, node.Arguments[0])
                ReplaceCurrentNode mie
            # Removes ICallable `.Call`
            case BooMethodCache.ICallable_Call:
                node.Target = (target as MemberReferenceExpression).Target
                # Convert varargs to plain arguments
                if len(node.Arguments) == 1 and node.Arguments.First.NodeType == NodeType.ArrayLiteralExpression:
                    lst = (node.Arguments.First as ArrayLiteralExpression).Items
                    node.Arguments.Clear()
                    for arg in lst:
                        node.Arguments.Add(arg)

            # Handle synthetic methods (ie Events)
            case InternalMethod(Method: Node(IsSynthetic: true)):
                # Map Event synthetic methods to our runtime
                if target.Name.StartsWith('raise_'):
                    target.Name = target.Name[len('raise_'):]
                elif target.Name.StartsWith('add_'):
                    target.Name = target.Name[len('add_'):] + '.add'
                elif target.Name.StartsWith('remove_'):
                    target.Name = target.Name[len('remove_'):] + '.remove'

            case IMethod(IsSpecialName: true):
                # Map Event synthetic methods to our runtime
                # TODO: Make sure they relate to an event (check if suffix is an event field?)
                if target.Name.StartsWith('raise_'):
                    target.Name = target.Name[len('raise_'):]
                elif target.Name.StartsWith('add_'):
                    target.Name = target.Name[len('add_'):] + '.add'
                elif target.Name.StartsWith('remove_'):
                    target.Name = target.Name[len('remove_'):] + '.remove'

            # Retarget builtins
            # TODO: Move to the prepare step?
            case IMethod() and TypeSystemServices.IsBuiltin(target.Entity):
                if target.NodeType == NodeType.MemberReferenceExpression:
                    (target as MemberReferenceExpression).Target = [| Boo |]
                else:
                    (target as ReferenceExpression).Name = 'Boo.' + (target as ReferenceExpression).Name

            otherwise:
                pass

    def LeaveMemberReferenceExpression(node as MemberReferenceExpression):
        # Map Event private field to the actual Event
        if node.Name.StartsWith('$event$'):
            node.Name = node.Name[len('$event$'):]



