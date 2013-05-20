namespace BooJs.Compiler.Steps

import Boo.Lang.Compiler.Steps(AbstractFastVisitorCompilerStep)
import Boo.Lang.Compiler.Ast
import Boo.Lang.Compiler.TypeSystem


class ExpandVarArgsMethodInvocations(AbstractFastVisitorCompilerStep):
"""
    This is a direct port of Boo's one. Using the original though there is a bug with
    invocations inside block expressions being converted to arrays twice.
"""
    public def Run():
        if len(Errors) > 0:
            return
        Visit(CompileUnit)

    override def OnMethodInvocationExpression(node as MethodInvocationExpression):
        # Make sure we only process invocations once
        return if node.ContainsAnnotation(self.GetType())
        node.Annotate(self.GetType())

        # Process first any invocations passed in as arguments
        Visit node.Arguments

        method = node.Target.Entity as IMethod;
        if (null != method and method.AcceptVarArgs):
            ExpandInvocation(node, method.GetParameters())
            return

        call = node.Target.ExpressionType as ICallableType
        if call != null:
            signature = call.GetSignature()
            if not signature.AcceptVarArgs: return

            ExpandInvocation(node, signature.Parameters)
            return

    protected virtual def ExpandInvocation(node as MethodInvocationExpression, parameters as (IParameter)):
        if AstUtil.InvocationEndsWithExplodeExpression(node):
            node.Arguments.ReplaceAt(-1, (node.Arguments[-1] as UnaryExpression).Operand)
            return

        lastParameterIndex = len(parameters)-1
        varArgType = parameters[lastParameterIndex].Type

        varArgs = node.Arguments.PopRange(lastParameterIndex)
        node.Arguments.Add(CodeBuilder.CreateArray(varArgType, varArgs))
