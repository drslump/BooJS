namespace BooJs.Compiler.Steps

import Boo.Lang.Compiler.Ast
import Boo.Lang.Compiler.Steps

class NormalizeUnpack(AbstractTransformerCompilerStep):
"""
    Boo allows to unpack an enumerable into local variables using the following construct:

        a, b, c = (10, 20, 30)

    In this step we convert that operation to the following statements:

        __unpack = (10, 20, 30)
        a = __unpack[0]
        b = __unpack[1]
        c = __unpack[2]
"""
    def EnterUnpackStatement(node as UnpackStatement):
        stmts = (node.ParentNode as Block).Statements
        idx = stmts.IndexOf(node)
        RemoveCurrentNode

        unpack = ReferenceExpression(Name: '__unpack')
        stmt = ExpressionStatement(Expression: [| $unpack = $(node.Expression) |])
        stmts.Insert(idx++, stmt)
        for i as int, decl as Declaration in enumerate(node.Declarations):
            refe = ReferenceExpression(Name: decl.Name)
            stmt = ExpressionStatement(Expression: [| $refe = $unpack[$i] |])
            stmts.Insert(idx++, stmt)
