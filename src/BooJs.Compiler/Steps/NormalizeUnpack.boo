namespace BooJs.Compiler.Steps

import Boo.Lang.Compiler.Ast
import Boo.Lang.Compiler.Steps

class NormalizeUnpack(AbstractTransformerCompilerStep):
"""
    Boo allows to unpack an enumerable into local variables using the following construct:

        a, b, c = (10, 20, 30)

    In this step we convert that operation to the following statements:

        @(upk = (10, 20, 30), a = upk[0], b = upk[1], c = upk[2])
"""
    static final REFERENCE_NAME = '__upk'

    def OnUnpackStatement(node as UnpackStatement):

        upkref = ReferenceExpression(node.LexicalInfo, REFERENCE_NAME)
        seq = CodeBuilder.CreateEvalInvocation(node.LexicalInfo)
        be = CodeBuilder.CreateAssignment(node.LexicalInfo, upkref, node.Expression)
        seq.Arguments.Add(be)
        for i as int, decl as Declaration in enumerate(node.Declarations):
            refe = ReferenceExpression(decl.LexicalInfo, decl.Name)
            slice = CodeBuilder.CreateSlicing(upkref, i)
            be = CodeBuilder.CreateAssignment(decl.LexicalInfo, refe, slice)
            seq.Arguments.Add(be)

        ReplaceCurrentNode ExpressionStatement(node.LexicalInfo, seq)