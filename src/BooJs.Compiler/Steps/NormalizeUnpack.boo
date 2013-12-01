namespace BooJs.Compiler.Steps

from Boo.Lang.Compiler.Ast import *
from Boo.Lang.Compiler.Steps import AbstractTransformerCompilerStep


class NormalizeUnpack(AbstractTransformerCompilerStep):
"""
    Boo allows to unpack an enumerable into local variables using the following construct:

        a, b, c = (10, 20, 30)

    In this step we convert that operation to the following statements:

        @(upk = (10, 20, 30), a = upk[0], b = upk[1], c = upk[2])

    TODO: Shall we allow to unpack generators too?
"""
    static final REFERENCE_NAME = 'upk'

    _method as Method = null

    def OnMethod(node as Method):
        _method = node
        super(node)

    def OnConstructor(node as Constructor):
        _method = node
        super(node)

    def OnUnpackStatement(node as UnpackStatement):

        seq = CodeBuilder.CreateEvalInvocation(node.LexicalInfo)

        # If the target to unpack is a reference just use it
        upkref as ReferenceExpression
        if node.Expression.NodeType == NodeType.ReferenceExpression:
            upkref = node.Expression
        else:
            upkref = ReferenceExpression(Name: Context.GetUniqueName(REFERENCE_NAME))
            seq.Arguments.Add( [| $upkref = $(node.Expression) |] )

        for i as int, decl as Declaration in enumerate(node.Declarations):
            seq.Arguments.Add( [| $(ReferenceExpression(decl.Name)) = $(upkref)[$i] |] )

        ReplaceCurrentNode ExpressionStatement(node.LexicalInfo, Expression: seq)
