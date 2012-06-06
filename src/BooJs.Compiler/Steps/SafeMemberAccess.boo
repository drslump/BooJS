namespace BooJs.Compiler.Steps

import Boo.Lang.Compiler.Ast
import Boo.Lang.Compiler.Steps

# TODO: Not yet working correctly
class SafeMemberAccess(AbstractTransformerCompilerStep):
"""
  a = foo?.bar
  (foo.bar if foo != null else null)

  a = foo?.bar?.baz
  (_ref.baz if (_ref=foo.bar if foo != null else null) != null else null)
  (foo.bar.baz if (foo.bar if foo != null else null) != null else null)

  a = foo?.bar?[2]
  (_ref[2] if (_ref=foo.bar if foo != null else null) != null else null)
  (foo.bar[2] if (foo.bar if foo != null else null) != null else null)

  a = foo?.bar?()
  (foo.bar() if (foo.bar if foo != null else null) != null else null)


Boo supports unicode letters as part of an identifier, we preprocess the source file
replacing occurences of `?` followed by `.`, `[`, or `(` with an unicode equivalent
which we can easily detect here to convert the expression to use a ternary operator.
"""

    final public static UNICODE_CHAR = '\u0294'      # LATIN LETTER GLOTTAL STOP "ʔ"


    override def Run():
        if len(Errors) > 0:
            return
        Visit CompileUnit

    def OnMemberReferenceExpression(node as MemberReferenceExpression):
        ReplaceCurrentNode( ApplyTernary(node) )


    def OnReferenceExpression(node as ReferenceExpression):
        if node.Name[-1:] == UNICODE_CHAR:
            node.Name = node.Name[:-1]


    protected def ApplyTernary(node as ReferenceExpression) as Expression:

        if node.NodeType == NodeType.MemberReferenceExpression:
            target = (node as MemberReferenceExpression).Target as ReferenceExpression
            if target.Name[-1:] == UNICODE_CHAR:
                target.Name = target.Name[:-1]

            n = ApplyTernary(target)

            return [| ($node if $n else null) |]

        return node


