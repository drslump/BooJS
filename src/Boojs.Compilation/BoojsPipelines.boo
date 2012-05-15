namespace Boojs.Compilation.BoojsPipelines

import Boojs.Compilation.Steps
import Boo.Lang.Compiler.Steps

def PatchBooPipeline(pipeline as Boo.Lang.Compiler.CompilerPipeline):
"""
Patches a boo pipeline to make it work like a boojay one.
"""


class Compile(Boo.Lang.Compiler.Pipelines.Compile):

    def constructor():
        Insert(0, InitializeEntityNameMatcher())
        InsertAfter(NormalizeTypeAndMemberDefinitions, NormalizeLiterals())
        Replace(IntroduceGlobalNamespaces, IntroduceBoojayNamespaces())

        # TODO: While in prototyping mode we abuse the Emitter instead of creating
        #       customized transformation steps
        #InsertBefore(NormalizeIterationStatements, NormalizeIterations())
        Remove(NormalizeIterationStatements)
        Remove(OptimizeIterationStatements)

        Add(NormalizeCallables())
        Add(PatchCallableConstruction())
        Add(InjectCasts())


class ProduceJs(Compile):

    def constructor():
        Add(PrintJs())
