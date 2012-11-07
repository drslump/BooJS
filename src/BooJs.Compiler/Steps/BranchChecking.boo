namespace BooJs.Compiler.Steps

import Boo.Lang.Compiler.Ast
import Boo.Lang.Compiler.Steps.BranchChecking as BooStep

class BranchChecking(BooStep):
""" Override Boo's step to allow lift the limit on yield statements
"""
    override def OnYieldStatement(node as YieldStatement):
        pass

