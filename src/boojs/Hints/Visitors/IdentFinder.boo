namespace boojs.Hints.Visitors

import Boo.Lang.Compiler.Ast


class IdentFinder(DepthFirstVisitor):
""" Looks for the a cursor location by checking member reference expression for
    the configured identifier.
"""
    _ident as string
    _node as MemberReferenceExpression

    def constructor(ident as string):
        _ident = ident

    def FindIn(root as Node) as MemberReferenceExpression:
        VisitAllowingCancellation(root)
        return _node

    override def LeaveMemberReferenceExpression(node as MemberReferenceExpression):
        if node.Name == _ident:
        	_node = node
        	Cancel()
