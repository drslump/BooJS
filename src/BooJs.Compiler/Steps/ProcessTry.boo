namespace BooJs.Compiler.Steps

import Boo.Lang.Compiler.Ast
import Boo.Lang.Compiler.Steps

class ProcessGoto(AbstractTransformerCompilerStep):
"""
    Process labels and goto statements

    The supported uses are very limited. It's only possible to jump to a label
    previously defined in the same function. No jumps to forward labels are
    allowed.

    Even if fully supporting goto statements with forward jumping is theoretically
    possible (similarly on how generators are transformed for example), it would be
    difficult to implement for the benefits it provides.

    TODO: Check implementation constraints. Referenced label can only
          be present in the same method and above the goto statement
"""
    override def Run():
        if len(Errors) > 0:
            return
        Visit CompileUnit

    def OnLabelStatement(node as LabelStatement):
        parent = node.ParentNode as Block
        index = parent.Statements.IndexOf(node)

        loop = [| 
            while true: pass 
        |]
        loop.Block.Statements = parent.Statements.PopRange(index+1)

        parent.Statements.Add(loop)



