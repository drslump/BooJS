namespace BooJs.Compiler.Steps

import Boo.Lang.Compiler
import Boo.Lang.Compiler.Ast
import Boo.Lang.Compiler.Steps
import Boo.Lang.Compiler.IO


class SafeAccess(AbstractTransformerCompilerStep):
"""
Desugarizes the safe access operator.

  foo?
  (true if foo is not null else false)

  foo?.bar?
  (true if (foo.bar if foo is not null else null) else false)

  foo?.bar
  (foo.bar if foo != null else null)

  foo?.bar?.baz
  (foo.bar.baz if (foo.bar if foo != null else null) != null else null)

  foo?.bar?[2]
  (foo.bar[2] if (foo.bar if foo != null else null) != null else null)

  foo?.bar?()
  (foo.bar() if (foo.bar if foo != null else null) != null else null)

"""
    override def LeaveUnaryExpression(node as UnaryExpression):
        return unless node.Operator == UnaryOperatorType.SafeAccess and not IsTarget(node)

        # target references should already be resolved, so just evaluate as existential
        tern = [| (true if $(node.Operand) is not null else false) |]
        ReplaceCurrentNode tern

    override def LeaveMemberReferenceExpression(node as MemberReferenceExpression):
        if target = node.Target as UnaryExpression:
            return unless target.Operator == UnaryOperatorType.SafeAccess

            node.Target = ReferenceExpression(Context.GetUniqueName('safe'))
            tern = [| ($node if ($(node.Target) = $(target.Operand)) is not null else null) |]
            ReplaceCurrentNode tern

    override def LeaveMethodInvocationExpression(node as MethodInvocationExpression):
        if target = node.Target as UnaryExpression:
            return unless target.Operator == UnaryOperatorType.SafeAccess

            node.Target = ReferenceExpression(Context.GetUniqueName('safe'))
            tern = [| ($node if ($(node.Target) = $(target.Operand)) is not null else null) |]
            ReplaceCurrentNode tern

    override def LeaveSlicingExpression(node as SlicingExpression):
        if target = node.Target as UnaryExpression:
            return unless target.Operator == UnaryOperatorType.SafeAccess

            node.Target = ReferenceExpression(Context.GetUniqueName('safe'))
            tern = [| ($node if ($(node.Target) = $(target.Operand)) is not null else null) |]
            ReplaceCurrentNode tern

    protected def IsTarget(node):
        return AstUtil.IsTargetOfMemberReference(node) or \
               AstUtil.IsTargetOfMethodInvocation(node) or \
               AstUtil.IsTargetOfSlicing(node)

