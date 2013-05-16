namespace boojs.Hints.Visitors

import Boo.Lang.Compiler.TypeSystem(IEntity)
import Boo.Lang.Compiler.Ast


class LineFinder(DepthFirstVisitor):
""" Looks for an expression based on line and column numbers.
"""
    _entity as IEntity
    _line as int
    _column as int

    def constructor(line as int, column as int):
        _line = line
        _column = column

    def FindIn(root as Node):
        VisitAllowingCancellation(root)
        return _entity

    override def Visit(node as Node):
        if node and not node.IsSynthetic and node.LexicalInfo is not null and node.Entity is not null:
            if node.LexicalInfo.Line == _line and node.LexicalInfo.Column == _column:
                _entity = node.Entity
                Cancel()

        super(node)
