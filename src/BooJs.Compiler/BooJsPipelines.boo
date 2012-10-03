namespace BooJs.Compiler.Pipelines

import Boo.Lang.Compiler.Steps
import BooJs.Compiler.Steps as Steps

class Compile(Boo.Lang.Compiler.Pipelines.Compile):
    def constructor():
        Insert(0, Steps.InitializeEntityNameMatcher())

        #InsertAfter(NormalizeTypeAndMemberDefinitions, NormalizeLiterals())
        Replace(IntroduceGlobalNamespaces, Steps.IntroduceNamespaces())

        # Process safe member access operator
        # NOTE: It must be added before and after the parsing step
        safe_member = Steps.SafeMemberAccess()
        InsertBefore(Parsing, safe_member)
        InsertAfter(Parsing, safe_member)

        # Check for unsupported features
        unsupported = Steps.UnsupportedFeatures()
        InsertAfter(Parsing, unsupported)
        InsertAfter(MacroAndAttributeExpansion, unsupported)

        # Since JS is dynamic we don't need the additional tooling for duck types
        #Remove(ExpandDuckTypedExpressions)
        # Same applies to Closures (TODO: Are we sure?)
        Remove(InjectCallableConversions)
        Remove(ProcessClosures)

        # No need to cache/precompile regexp in Javascript
        Remove(CacheRegularExpressionsInStaticFields)

        # Undo some of the stuff performed by ProcessMethodBodies
        InsertAfter(ProcessMethodBodiesWithDuckTyping, Steps.UndoProcessMethod())
        # Override some of the stuff in the gigantic ProcessMethodBodies step
        Replace(ProcessMethodBodiesWithDuckTyping, Steps.OverrideProcessMethodBodies())

        # Customize slicing expressions
        # HACK: MonoDevelop version of Boo doesn't have this step so the compilation fails
        #Replace(ExpandComplexSlicingExpressions, Steps.ExpandComplexSlicingExpressions())
        #InsertAfter(ExpandDuckTypedExpressions, Steps.ExpandComplexSlicingExpressions())
        InsertAfter(MacroAndAttributeExpansion, Steps.ExpandComplexSlicingExpressions())

        # Relax boolean conversions
        Replace(InjectImplicitBooleanConversions, Steps.InjectImplicitBooleanConversions())

        # Normalize generator expressions
        InsertAfter(MacroAndAttributeExpansion, Steps.NormalizeGeneratorExpression())

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

        # Normalize method invocations
        Add(Steps.NormalizeMethodInvocation())

        # Normalize closures
        Add(Steps.NormalizeClosures())

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
