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

        # Since JS is dynamic we don't need the additional tooling for duck types
        Remove(ExpandDuckTypedExpressions)
        # Same applies to Closures
        Remove(InjectCallableConversions)
        Remove(ProcessClosures)

        #Add(NormalizeCallables())
        #Add(PatchCallableConstruction())
        #Add(InjectCasts())

        Add(UndoProcessMethod())

        for step in self:
            print step


class ProduceJs(Compile):

    def constructor():
        a = 1
        Add(PrintJs())
