namespace BooJs.Compiler.Steps

from Boo.Lang.Compiler.Ast import *
from Boo.Lang.Compiler.Steps import AbstractTransformerCompilerStep


class NormalizeLiterals(AbstractTransformerCompilerStep):

    def Run():
        Visit CompileUnit

    protected def IsEmptyString(node as Expression):
        str = node as StringLiteralExpression
        return str and str.Value == ''

    def LeaveExpressionInterpolationExpression(node as ExpressionInterpolationExpression):
    """ We build a string concatenation. Modern browsers apply excellent optimizations
        for this use case, avoiding the need to build an array an joining it afterwards
        as was done previously
    """
        items = node.Expressions

        # Trim the expression
        items.Remove(items.First) while IsEmptyString(items.First)
        items.Remove(items.Last) while IsEmptyString(items.Last)

        repl = items.First
        items.Remove(items.First)
        while items.First:
            # HACK: Binary expressions are wrapped with an eval to disambiguate special
            #       cases like "foo $( 10 + 10 )" to become: "foo" + (10 + 10)
            if items.First.NodeType == NodeType.BinaryExpression:
                repl = [| $repl + @( $(items.First) ) |]
            else:
                repl = [| $repl + $(items.First) |]

            items.Remove(items.First)

        ReplaceCurrentNode repl

    def OnTimeSpanLiteralExpression(node as TimeSpanLiteralExpression):
    """ Convert timespan literal values to milliseconds
    """
        ReplaceCurrentNode IntegerLiteralExpression(Value: node.Value.TotalMilliseconds)
