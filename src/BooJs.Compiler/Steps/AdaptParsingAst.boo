namespace BooJs.Compiler.Steps

import Boo.Lang.Compiler.Ast
import Boo.Lang.Compiler.Steps

class NormalizeLiterals(AbstractTransformerCompilerStep):

    static public final INTERPOLATION_MAX_ITEMS = 3
    
    def Run():
        Visit CompileUnit

    protected def IsEmptyString(node as Expression):
        str = node as StringLiteralExpression
        return str and str.Value == ''

    def OnGenericTypeReference(node as GenericTypeReference):
        # HACK: Replace references to IEnumerable for Array ones. Boo's parser
        #       defines <type>* as a generic type reference to IEnumerable.
        if node.Name == 'System.Collections.Generic.IEnumerable':
            node.Name = 'BooJs.Lang.Globals.Array'


    def LeaveExpressionInterpolationExpression(node as ExpressionInterpolationExpression):
    """ We build either as string concatenation or as a literal array and then join it to form the string
            "foo \$bar" => 'foo' + bar
            "foo \$bar \$baz" -> ['foo', bar, ' ', baz].join('')
    """
        items = node.Expressions

        # Trim the expression
        while IsEmptyString(items.First): items.Remove(items.First)
        while IsEmptyString(items.Last): items.Remove(items.Last)

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

