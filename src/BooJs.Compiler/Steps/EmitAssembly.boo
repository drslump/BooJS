namespace BooJs.Compiler.Steps

from System import Guid
from System.IO import Path

from Boo.Lang.Compiler.Ast import *
from Boo.Lang.Compiler import CompilerContext
from Boo.Lang.Compiler.Steps import EmitAssembly as BooEmitAssembly, ContextAnnotations


# TODO: Do not remove non visible types which are referenced (inherited, arguments, etc.)
# TODO: Perhaps it's better to leave this without removing anything. The size savings
#       are not that much and we may introduce subtle bugs.
class EmitAssembly(BooEmitAssembly):

    private class Stripper(DepthFirstTransformer):

        def OnModule(node as Module):
            if not node.IsVisible:
                RemoveCurrentNode
            # TODO: Callables need these modules
            #elif node.Name == 'CompilerGenerated':
            #    RemoveCurrentNode
            else:
                super(node)

        def OnClassDefinition(node as ClassDefinition):
            unless node.IsVisible:
                RemoveCurrentNode
                return

            super(node)

        def OnStructDefinition(node as StructDefinition):
            unless node.IsVisible:
                RemoveCurrentNode
                return

            super(node)

        def OnEnumDefinition(node as EnumDefinition):
            unless node.IsVisible:
                RemoveCurrentNode
                return

            super(node)

        def OnField(node as Field):
            unless node.IsVisible:
                RemoveCurrentNode
                return

            super(node)

        def OnMethod(node as Method):
            # Skip non visible methods
            unless node.IsVisible or node is ContextAnnotations.GetEntryPoint(CompilerContext.Current):
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

        # Setup a temporary location for the assembly
        # TODO: We should set this up when configuring the compiler
        path = Path.GetTempPath()
        fname = System.Guid.NewGuid().ToString() + '.bjsasm'

        orig_fname = Parameters.OutputAssembly
        Parameters.OutputAssembly = Path.Combine(path, fname)

        # Emit the assembly
        super()

        Parameters.OutputAssembly = orig_fname or '.'

        # Restore the AST to its previous step now that the assembly has been generated
        CompileUnit.Modules = saved
