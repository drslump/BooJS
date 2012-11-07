namespace BooJs.Compiler.Steps

import Boo.Lang.Compiler.Ast
import Boo.Lang.Compiler.Steps

class NormalizeGeneratorExpression(AbstractTransformerCompilerStep):
"""
    Converts generator expressions to a simpler form using a sequence/eval
"""

    _depth = 0

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

    def EnterGeneratorExpression(node as GeneratorExpression):
        _depth++
        return true

    def LeaveGeneratorExpression(node as GeneratorExpression):
    """ Convert generator expressions to a sequence:

        ( i*2 for i in range(3) )  =>  @(__gen = [], Boo.each(range(3), { i | __gen.push(i*2) }), __gen)

    """
        _depth--

        # Make sure the gen temporary variable is declared
        genref = ReferenceExpression(node.LexicalInfo, '__gen' + _depth)
        _method.Locals.Add(Local(node.LexicalInfo, genref.Name))

        if node.Filter and node.Filter.Type == StatementModifierType.If:
            lambda = [| { $(node.Filter.Condition) and $(genref).push( $(node.Expression) ) } |]
        elif node.Filter and node.Filter.Type == StatementModifierType.Unless:
            lambda = [| { $(node.Filter.Condition) or $(genref).push( $(node.Expression) ) } |]
        else:
            lambda = [| { $(genref).push( $(node.Expression) ) } |]

        lambda.LexicalInfo = node.LexicalInfo
        for decl in node.Declarations:
            lambda.Parameters.Add(ParameterDeclaration(node.LexicalInfo, Name: decl.Name))

        eval = CodeBuilder.CreateEvalInvocation(node.LexicalInfo)
        eval.Arguments.Add( [| $genref = [] |] )
        eval.Arguments.Add( [| Boo.each($(node.Iterator), $lambda) |] )
        eval.Arguments.Add( [| $genref |] )
        ReplaceCurrentNode eval

