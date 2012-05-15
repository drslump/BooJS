namespace Boojs.Compiler.BoojsPipelines

import Boo.Lang.Compiler.Steps
import Boojs.Compiler.Steps

class Compile(Boo.Lang.Compiler.Pipelines.Compile):

    def constructor():
        # TODO: While in prototyping mode we abuse the Emitter instead of creating
        #       customized transformation steps

        Insert(0, InitializeEntityNameMatcher())
        #InsertAfter(NormalizeTypeAndMemberDefinitions, NormalizeLiterals())
        Replace(IntroduceGlobalNamespaces, IntroduceNamespaces())

        #InsertBefore(NormalizeIterationStatements, NormalizeIterations())
        Remove(NormalizeIterationStatements)
        Remove(OptimizeIterationStatements)

        Add(NormalizeCallables())
        Add(PatchCallableConstruction())
        /*Add(InjectCasts())*/


class ProduceJs(Compile):

    def constructor():

        Add(PrintJs())
