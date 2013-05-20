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

    _method as Method = null

    def OnMethod(node as Method):
        _method = node
        super(node)

    def OnConstructor(node as Constructor):
        _method = node
        super(node)

    def OnUnpackStatement(node as UnpackStatement):
        # Create a local for the unpack holder and flag it as used
        local = CodeBuilder.DeclareLocal(_method, REFERENCE_NAME, TypeSystemServices.ListType)
        local.IsUsed = true

        # Build the sequence to unpack the values
        upkref = CodeBuilder.CreateLocalReference(REFERENCE_NAME, local)
        seq = CodeBuilder.CreateEvalInvocation(node.LexicalInfo)
        be = CodeBuilder.CreateAssignment(node.LexicalInfo, upkref, node.Expression)
        seq.Arguments.Add(be)
        for i as int, decl as Declaration in enumerate(node.Declarations):
            refe = ReferenceExpression(decl.LexicalInfo, decl.Name)
            slice = CodeBuilder.CreateSlicing(upkref, i)
            be = CodeBuilder.CreateAssignment(decl.LexicalInfo, refe, slice)
            seq.Arguments.Add(be)

        ReplaceCurrentNode ExpressionStatement(node.LexicalInfo, seq)
