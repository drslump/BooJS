namespace BooJs.Macros

import Boo.Lang.Compiler.Ast


macro global:
""" Avoids the definition of locally scoped variables in order to access
    global values, for example the `window` object.

        global console   # Binds to the duck type by default
        global mystr as string = 'override global value'
"""
    if len(global.Arguments) != 1:
        raise System.ArgumentException('Expected an identifier (ie: global console)')

    node = global.Arguments[0]
    decl = Declaration()
    decl.Annotate('global')
    stmt = DeclarationStatement(Declaration: decl)

    if node.NodeType == NodeType.TryCastExpression:
        decl.Name = (node as TryCastExpression).Target.ToString()
        decl.Type = (node as TryCastExpression).Type
    elif node.NodeType == NodeType.BinaryExpression:
        be = node as BinaryExpression
        if be.Left.NodeType == NodeType.TryCastExpression:
            decl.Name = (be.Left as TryCastExpression).Target.ToString()
            decl.Type = (be.Left as TryCastExpression).Type
        else:
            decl.Name = be.Left.ToString()
        stmt.Initializer = (node as BinaryExpression).Right
    else:
        decl.Name = node.ToString()
        decl.Type = SimpleTypeReference('duck')

    return stmt
