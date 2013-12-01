namespace BooJs.Lang.Macros

from Boo.Lang.Compiler.Ast import *
from Boo.Lang.Compiler import CompilerContext


internal class OmittedExpressionFinder(FastDepthFirstVisitor):

    _target as ReferenceExpression

    def constructor(target as ReferenceExpression):
        _target = target

    override def OnMemberReferenceExpression(node as MemberReferenceExpression):
        if node.Target isa OmittedExpression:
            node.Target = _target


macro with(target):
""" Omitted targets get rewrited to the given one

        with My.Long.Named.Object:
            .foo = 'FOOBAR'
            .bar = 1000

        with date = Date():
            .setUTCFullYear(2000, 0, 1)
            .setUTCHours(0, 0, 0)
"""
    if be = target as BinaryExpression and be.Operator = BinaryOperatorType.Assign:
        yield target
        target = be.Left
    elif target.NodeType != NodeType.ReferenceExpression:
        tmp = ReferenceExpression(CompilerContext.Current.GetUniqueName('with'))
        yield [| $tmp = $target |]
        target = tmp

    finder = OmittedExpressionFinder(target)
    finder.OnBlock(with.Body)
    yield with.Body
