namespace boojs


import Boo.Lang.Compiler.Ast(Node)
import Boo.Lang.Compiler.Pipelines(Parse)
import Boo.Lang.Compiler.Steps

class LintPipeline(Parse):
""" Check http://docs.codehaus.org/display/BOO/Boo+Style+Checker for ideas of what to check
"""
    def constructor():
        BreakOnErrors = false
        Add PreErrorChecking()
        Add HackedStricterErrorChecking()


class HackedStricterErrorChecking(StricterErrorChecking):
""" Silently ignore internal errors produced by running this step before resolving the symbols
"""
    override def OnError(node as Node, error as System.Exception):
        pass

