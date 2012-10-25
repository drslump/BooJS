namespace BooJs.Compiler.Steps

import Boo.Lang.Compiler.Ast
import Boo.Lang.Compiler.Steps

# TODO: Strip all unneeded members
class PrepareForEmit(AbstractTransformerCompilerStep):

    def Run():
        if len(Errors) > 0:
            return

        Visit CompileUnit

    def OnModule(node as Module):
        if node.Name == 'CompilerGenerated':
            RemoveCurrentNode()

    def EnterClassDefinition(node as ClassDefinition):
        if node.Name == 'CompilerGeneratedExtensions':
            RemoveCurrentNode()

    def OnField(node as Field):
        if not node.IsVisible:
            RemoveCurrentNode

    def OnMethod(node as Method):
        # Skip compiler generated methods
        if node.IsSynthetic and node.IsInternal:
            RemoveCurrentNode
        elif not node.IsVisible:
            RemoveCurrentNode
        else:
            # Remove all the statements
            node.Body.Clear()


