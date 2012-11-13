namespace BooJs.Compiler.Steps

import Boo.Lang.Compiler.Ast
import Boo.Lang.Compiler.Steps(AbstractTransformerCompilerStep)


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
  (foo.bar.baz if (foo.bar if foo is not null else null) is not null else null)

  foo?.bar?[2]
  (foo.bar[2] if (foo.bar if foo is not null else null) is not null else null)

  foo?.bar?()
  (foo.bar() if (foo.bar if foo is not null else null) is not null else null)

"""
    override def LeaveUnaryExpression(node as UnaryExpression):
        return unless node.Operator == UnaryOperatorType.SafeAccess and not IsTarget(node)

        # target references should already be resolved, so just evaluate as existential
        tern = [| (true if $(node.Operand) is not null else false) |]
        ReplaceCurrentNode tern

    override def OnMemberReferenceExpression(node as MemberReferenceExpression):
        tern = ProcessTargets(node)
        if tern:
            ReplaceCurrentNode tern
        else:
            super(node)

    override def OnMethodInvocationExpression(node as MethodInvocationExpression):
        tern = ProcessTargets(node)
        if tern:
            ReplaceCurrentNode tern
        else:
            super(node)

    override def OnSlicingExpression(node as SlicingExpression):
        tern = ProcessTargets(node)
        if tern:
            ReplaceCurrentNode tern
        else:
            super(node)

    protected def IsTargetable(node) as bool:
        return node isa MemberReferenceExpression or \
               node isa MethodInvocationExpression or \
               node isa SlicingExpression

    protected def ProcessTargets(node as Expression) as Expression:
        # Look for safe access operators in the targets chain
        ue as UnaryExpression
        target as duck = node
        while IsTargetable(target):
            break if ue = target.Target as UnaryExpression and ue.Operator == UnaryOperatorType.SafeAccess
            target = target.Target

        # No safe access operator was found
        if not ue or ue.Operator != UnaryOperatorType.SafeAccess:
            return null

        # Make sure previous access operators are processed
        Visit(target.Target as Expression)

        # Target the safe access to a temporary variable
        tmp = ReferenceExpression(Context.GetUniqueName('safe'))
        target.Target = tmp
        # Break the targets chain into a ternary operation
        tern = [| ($node if ($tmp = $(ue.Operand)) is not null else null) |]
        return tern

    protected def IsTarget(node):
        return AstUtil.IsTargetOfMemberReference(node) or \
               AstUtil.IsTargetOfMethodInvocation(node) or \
               AstUtil.IsTargetOfSlicing(node)
