namespace BooJs.Compiler.Steps

from Boo.Lang.Compiler.Ast import *
from Boo.Lang.Compiler.Steps import BranchChecking as BooStep


class BranchChecking(BooStep):
""" Override Boo's step to lift the limit on yield statements
"""
    override def OnYieldStatement(node as YieldStatement):
        pass

