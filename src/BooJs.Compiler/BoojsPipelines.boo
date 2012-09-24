namespace BooJs.Compiler.Pipelines

import Boo.Lang.Compiler.Steps
import BooJs.Compiler.Steps as Steps

class Compile(Boo.Lang.Compiler.Pipelines.Compile):
    def constructor():
        Insert(0, Steps.InitializeEntityNameMatcher())
        #InsertAfter(NormalizeTypeAndMemberDefinitions, NormalizeLiterals())
        Replace(IntroduceGlobalNamespaces, Steps.IntroduceNamespaces())

        # Process safe member access operator
        # TODO: Do not enable until we have a more solid implementation
        #InsertBefore(Parsing, Steps.Preprocess())
        #InsertAfter(Parsing, Steps.SafeMemberAccess())

        # Check for unsupported features
        InsertAfter(Parsing, Steps.UnsupportedFeatures())
        InsertAfter(MacroAndAttributeExpansion, Steps.UnsupportedFeatures())

        # Since JS is dynamic we don't need the additional tooling for duck types
        Remove(ExpandDuckTypedExpressions)
        # Same applies to Closures
        Remove(InjectCallableConversions)
        Remove(ProcessClosures)
        # No need to cache/precompile regexp in Javascript
        Remove(CacheRegularExpressionsInStaticFields)

        # Undo some of the stuff performed by ProcessMethodBodies
        InsertAfter(ProcessMethodBodiesWithDuckTyping, Steps.UndoProcessMethod())
        # Override some of the stuff in the gigantic ProcessMethodBodies step
        Replace(ProcessMethodBodiesWithDuckTyping, Steps.OverrideProcessMethodBodies())

        # Relax boolean conversions
        Replace(InjectImplicitBooleanConversions, Steps.InjectImplicitBooleanConversions())

        # Use a custom implementation for iterations
        Remove(NormalizeIterationStatements)
        Remove(OptimizeIterationStatements)
        Add(Steps.NormalizeLoops())

        # Simplify the unpack operations
        InsertAfter(NormalizeStatementModifiers, Steps.NormalizeUnpack())

        # Adapt try/except statements
        Add(Steps.ProcessTry())

        # Support `goto`
        Add(Steps.ProcessGoto())

        # Normalize closures
        Add(Steps.NormalizeClosures())

        # Normalize method invocations
        Add(Steps.NormalizeMethodInvocation())

        # Use our custom generators processing
        Replace(ProcessGenerators, Steps.ProcessGenerators())


        #for step in self:
        #    print step


class ProduceBoo(Compile):
    def constructor():
        Add(PrintBoo())


class ProduceBooJs(Compile):
    def constructor():
        #Add(PrintAst())
        #Add(PrintBoo())
        Add(Steps.PrintBooJs())
