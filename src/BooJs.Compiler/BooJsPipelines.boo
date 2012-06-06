namespace Boojs.Compiler.BoojsPipelines

import Boo.Lang.Compiler.Steps
import Boojs.Compiler.Steps as Steps

class Compile(Boo.Lang.Compiler.Pipelines.Compile):
    def constructor():
        # TODO: While in prototyping mode we abuse the Emitter instead of creating
        #       customized transformation steps

        Insert(0, Steps.InitializeEntityNameMatcher())
        #InsertAfter(NormalizeTypeAndMemberDefinitions, NormalizeLiterals())
        Replace(IntroduceGlobalNamespaces, Steps.IntroduceNamespaces())

        # Check for unsupported features
        InsertAfter(Parsing, Steps.UnsupportedFeatures())
        InsertAfter(MacroAndAttributeExpansion, Steps.UnsupportedFeatures())

        #InsertBefore(NormalizeIterationStatements, NormalizeIterations())
        Remove(NormalizeIterationStatements)
        Remove(OptimizeIterationStatements)

        # Since JS is dynamic we don't need the additional tooling for duck types
        Remove(ExpandDuckTypedExpressions)
        # Same applies to Closures
        Remove(InjectCallableConversions)
        Remove(ProcessClosures)

        # Disable generator processing
        Replace(ProcessGenerators, Steps.ProcessGenerators())

        #Add(NormalizeCallables())
        #Add(PatchCallableConstruction())
        #Add(InjectCasts())

        Add(Steps.UndoProcessMethod())

        Add(Steps.NormalizeLoops())
        Add(Steps.ProcessGoto())

        #for step in self:
        #    print step

class ProduceBoo(Compile):
    def constructor():
        Add(PrintBoo())

class ProduceJs(Compile):
    def constructor():
        Add(Steps.PrintJs())
