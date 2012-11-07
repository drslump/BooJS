namespace BooJs.Lang.Macros

import Boo.Lang.Compiler.Ast


macro const:
""" Allows to define constants at the module level

        const FOOBAR = 'FOOBAR'
"""
    if len(const.Arguments) != 1 or const.Arguments[0].NodeType != NodeType.BinaryExpression:
        raise System.ArgumentException('Expected an assignment (ie: const foo = 10)')

    node = const.Arguments[0] as BinaryExpression

    f = Field()
    f.Name = (node.Left as ReferenceExpression).Name
    f.Initializer = node.Right
    f.Modifiers = TypeMemberModifiers.Public | TypeMemberModifiers.Static | TypeMemberModifiers.Final
    yield f

