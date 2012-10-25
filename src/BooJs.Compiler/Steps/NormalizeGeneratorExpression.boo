namespace BooJs.Compiler.Steps

import Boo.Lang.Compiler.Ast
import Boo.Lang.Compiler.Steps

class NormalizeGeneratorExpression(AbstractTransformerCompilerStep):
"""
    Converts generator expressions to a simpler form using a sequence/eval
"""

    # Keep track of last visited method
    _method as Method
    def OnMethod(node as Method):
        last = _method
        _method = node
        super(node)
        _method = last

    def OnListLiteralExpression(node as ListLiteralExpression):
    """ If generator is contained in a list literal, remove the list literal
    """
        if len(node.Items) == 1 and node.Items.First.NodeType == NodeType.GeneratorExpression:
            result = Visit(node.Items.First)
            ReplaceCurrentNode result
            return

        super(node)

    def LeaveGeneratorExpression(node as GeneratorExpression):
    """ Convert generator expressions to a sequence:

        ( i*2 for i in range(3) )  =>  @(__gen = [], Boo.each(range(3), { i | __gen.push(i*2) }), __gen)

    """
        # Make sure the __gen variable is declared
        _method.Locals.Add(Local(node.LexicalInfo, '__gen'))

        if node.Filter:
            lambda = [| { $(node.Filter.Condition) and __gen.push( $(node.Expression) ) } |]
        else:
            lambda = [| { __gen.push( $(node.Expression) ) } |]

        lambda.LexicalInfo = node.LexicalInfo
        for decl in node.Declarations:
            lambda.Parameters.Add(ParameterDeclaration(node.LexicalInfo, Name: decl.Name))

        eval = CodeBuilder.CreateEvalInvocation(node.LexicalInfo)
        eval.Arguments.Add( [| __gen = [] |] )
        eval.Arguments.Add( [| Boo.each($(node.Iterator), $lambda) |] )
        eval.Arguments.Add( [| __gen |] )
        ReplaceCurrentNode eval

