namespace BooJs.Compiler.Steps

import Boo.Lang.Compiler.Ast
import Boo.Lang.Compiler(CompilerContext)
import Boo.Lang.Compiler.Steps.EmitAssembly as BooEmitAssembly
import Boo.Lang.Compiler.Steps(ContextAnnotations)


# TODO: Do not remove non visible types which are referenced (inherited, arguments, etc.)
class EmitAssembly(BooEmitAssembly):

    private class Stripper(DepthFirstTransformer):

        def OnModule(node as Module):
            if not node.IsVisible:
                RemoveCurrentNode
            elif node.Name == 'CompilerGenerated':
                RemoveCurrentNode
            else:
                super(node)

        def OnClassDefinition(node as ClassDefinition):
            if not node.IsVisible:
                RemoveCurrentNode
            else:
                super(node)

        def OnStructDefinition(node as StructDefinition):
            if not node.IsVisible:
                RemoveCurrentNode
            else:
                super(node)

        def OnEnumDefinition(node as EnumDefinition):
            if not node.IsVisible:
                RemoveCurrentNode
            else:
                super(node)

        def OnField(node as Field):
            if not node.IsVisible:
                RemoveCurrentNode
            else:
                super(node)

        def OnMethod(node as Method):
            # Skip non visible methods
            if not node.IsVisible and node is not ContextAnnotations.GetEntryPoint(CompilerContext.Current):
                RemoveCurrentNode
                return

            # Remove all locals and statements
            node.Locals.Clear()
            node.Body.Clear()

            super(node)

        def OnConstructor(node as Constructor):
            OnMethod(node)



    static stripper = Stripper()

    def Run():
        return if len(Errors) > 0

        # Save a copy of the current AST
        saved = CompileUnit.Modules.Clone()

        # Remove non visible contents
        stripper.Visit(CompileUnit)

        # Emit the assembly
        super()

        # Restore the AST to its previous step now that the assembly has been generated
        CompileUnit.Modules = saved

