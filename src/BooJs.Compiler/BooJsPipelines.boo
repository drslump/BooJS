namespace BooJs.Compiler.Pipelines

import Boo.Lang.Compiler.Steps
import BooJs.Compiler.Steps as Steps


class Compile(Boo.Lang.Compiler.Pipelines.Compile):
    def constructor():
        # TODO: Do we need this?
        Insert(0, Steps.InitializeEntityNameMatcher())

        Replace(IntroduceGlobalNamespaces, Steps.IntroduceGlobalNamespaces())

        # Process safe member access operator
        # NOTE: It must be added before and after the parsing step
        safe_member = Steps.SafeMemberAccess()
        InsertBefore(Parsing, safe_member)
        InsertAfter(Parsing, safe_member)

        # Check for unsupported features
        unsupported = Steps.UnsupportedFeatures()
        InsertAfter(Parsing, unsupported)
        InsertAfter(MacroAndAttributeExpansion, unsupported)

        Replace(ExpandDuckTypedExpressions, Steps.ExpandDuckTypedExpressions())

        # TODO: Not sure we need this. It just seems to convert closure blocks
        #       to compiler generated classes.
        Remove(ProcessClosures)

        # TODO: Not sure we need this. The nodes should be already bound to the
        #       correct values, this only seems to be needed to support the
        #       additional instrumentation used by Boo to support callables.
        Remove(InjectCallableConversions)

        # No need to cache/precompile regexp in Javascript
        Remove(CacheRegularExpressionsInStaticFields)

        # Undo some of the stuff performed by ProcessMethodBodies
        InsertAfter(ProcessMethodBodiesWithDuckTyping, Steps.UndoProcessMethod())
        # Apply modifications to support method overloading
        InsertAfter(ProcessMethodBodiesWithDuckTyping, Steps.MethodOverloading())
        # Override some of the stuff in the gigantic ProcessMethodBodies step
        Replace(ProcessMethodBodiesWithDuckTyping, Steps.OverrideProcessMethodBodies())

        # Customize slicing expressions
        Replace(ExpandComplexSlicingExpressions, Steps.ExpandComplexSlicingExpressions())
        #InsertAfter(ExpandDuckTypedExpressions, Steps.ExpandComplexSlicingExpressions())
        #InsertAfter(MacroAndAttributeExpansion, Steps.ExpandComplexSlicingExpressions())

        # Relax boolean conversions
        Replace(InjectImplicitBooleanConversions, Steps.InjectImplicitBooleanConversions())

        # Normalize generator expressions
        InsertAfter(MacroAndAttributeExpansion, Steps.NormalizeGeneratorExpression())

        # Normalize literals
        InsertAfter(NormalizeTypeAndMemberDefinitions, Steps.NormalizeLiterals())

        # Use a custom implementation for iterations
        InsertBefore(NormalizeIterationStatements, Steps.NormalizeLoops())
        Remove(NormalizeIterationStatements)
        Remove(OptimizeIterationStatements)

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

        # Prepare the AST to be printed
        Add(Steps.PrepareAst())

        #for step in self: print step


class ProduceBoo(Compile):
    def constructor():
        Add(PrintBoo())

class ProduceJs(Compile):
    def constructor():
        Add(Steps.MozillaAst())
        Add(Steps.PrintJs())

class ProduceAst(Compile):
    def constructor():
        Add(Steps.MozillaAst())
        Add(Steps.PrintAst())
