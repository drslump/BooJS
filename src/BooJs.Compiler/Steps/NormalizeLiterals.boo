namespace BooJs.Compiler.Steps

from Boo.Lang.Compiler.Ast import *
from Boo.Lang.Compiler.Steps import AbstractTransformerCompilerStep


class NormalizeLiterals(AbstractTransformerCompilerStep):

    static public final INTERPOLATION_MAX_ITEMS = 3
    
    def Run():
        Visit CompileUnit

    protected def IsEmptyString(node as Expression):
        str = node as StringLiteralExpression
        return str and str.Value == ''

    def LeaveExpressionInterpolationExpression(node as ExpressionInterpolationExpression):
    """ We build either as a string concatenation or as a literal array and a join
            "foo \$bar" => 'foo' + bar
            "foo \$bar \$baz" -> ['foo', bar, ' ', baz].join('')
    """
        items = node.Expressions

        # Trim the expression
        items.Remove(items.First) while IsEmptyString(items.First)
        items.Remove(items.Last) while IsEmptyString(items.Last)

        if len(items) < INTERPOLATION_MAX_ITEMS:
            repl = items.First
            items.Remove(items.First)
            while items.First:
                repl = [| $repl + $(items.First) |]
                items.Remove(items.First)
        else:
            repl = [| $(ArrayLiteralExpression(Items: items)).join('') |]

        ReplaceCurrentNode repl

    def OnTimeSpanLiteralExpression(node as TimeSpanLiteralExpression):
    """ Convert timespan literal values to milliseconds
    """
        ReplaceCurrentNode IntegerLiteralExpression(Value: node.Value.TotalMilliseconds)
