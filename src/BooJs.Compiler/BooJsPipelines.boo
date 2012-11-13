namespace BooJs.Compiler.Pipelines

import Boo.Lang.Compiler.Steps
import BooJs.Compiler.Steps as Steps


class Compile(Boo.Lang.Compiler.Pipelines.Compile):
    def constructor():
        # TODO: Do we need this?
        Insert 0, Steps.InitializeEntityNameMatcher()

        # Process safe member access operator
        InsertAfter Parsing, Steps.SafeAccess()

        Replace IntroduceGlobalNamespaces, Steps.IntroduceGlobalNamespaces()

        # Make sure the parsing generated AST fits our needs
        InsertAfter Parsing, Steps.AdaptParsingAst()

        # Check for unsupported features
        unsupported = Steps.UnsupportedFeatures()
        InsertAfter Parsing, unsupported
        InsertAfter MacroAndAttributeExpansion, unsupported


        Replace ExpandDuckTypedExpressions, Steps.ExpandDuckTypedExpressions()

        Replace ExpandVarArgsMethodInvocations, Steps.ExpandVarArgsMethodInvocations()

        # TODO: Not sure we need this. It just seems to convert closure blocks
        #       to compiler generated classes.
        Remove ProcessClosures

        # TODO: Not sure we need this. The nodes should be already bound to the
        #       correct values, this only seems to be needed to support the
        #       additional instrumentation used by Boo to support callables.
        Remove InjectCallableConversions

        # No need to cache/precompile regexp in Javascript
        Remove CacheRegularExpressionsInStaticFields

        # Undo some of the stuff performed by ProcessMethodBodies
        InsertAfter ProcessMethodBodiesWithDuckTyping, Steps.UndoProcessMethod()
        # Apply modifications to support method overloading
        InsertAfter ProcessMethodBodiesWithDuckTyping, Steps.MethodOverloading()
        # Override some of the stuff in the gigantic ProcessMethodBodies step
        Replace ProcessMethodBodiesWithDuckTyping, Steps.OverrideProcessMethodBodies()

        # Customize slicing expressions
        Replace ExpandComplexSlicingExpressions, Steps.ExpandComplexSlicingExpressions()

        # Relax boolean conversions
        Replace InjectImplicitBooleanConversions, Steps.InjectImplicitBooleanConversions()

        # Normalize generator expressions
        #InsertAfter(MacroAndAttributeExpansion, Steps.NormalizeGeneratorExpression())

        # Normalize literals
        InsertAfter NormalizeTypeAndMemberDefinitions, Steps.NormalizeLiterals()

        # Use a custom implementation for iterations
        InsertBefore NormalizeIterationStatements, Steps.NormalizeLoops()
        Remove NormalizeIterationStatements
        Remove OptimizeIterationStatements

        # Simplify the unpack operations
        InsertAfter NormalizeStatementModifiers, Steps.NormalizeUnpack()

        # Adapt try/except statements
        Add Steps.ProcessTry()

        # Normalize method invocations
        Add Steps.NormalizeMethodInvocation()

        # Normalize closures
        Add Steps.NormalizeClosures()

        Add Steps.NormalizeGeneratorExpression()

        # Use our custom generators processing
        Replace BranchChecking, Steps.BranchChecking()  # Lift limitation for yield staments in try/except blocks
        Replace ProcessGenerators, Steps.ProcessGenerators()

        # Support `goto`
        Add Steps.ProcessGoto()

        # Disable int literals range checks
        Remove CheckLiteralValues

        # Generate assembly
        # TODO: This should be optional
        Add Steps.EmitAssembly()

        # Prepare the AST to be printed
        Add Steps.ProcessImports()
        Add Steps.PrepareAst()
        Add Steps.MozillaAst()

        #for step in self: print step


class PrintBoo(Compile):
    def constructor():
        Add PrintBoo()

class PrintJs(Compile):
    def constructor():
        Add Steps.PrintJs()

class PrintAst(Compile):
    def constructor():
        Add Steps.PrintAst()

class SaveJs(Compile):
    def constructor():
        Add Steps.Save()