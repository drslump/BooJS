namespace BooJs.Compiler.Pipelines

import Boo.Lang.Compiler(CompilerPipeline)
import Boo.Lang.Compiler.Steps
import Boo.Lang.Compiler.Pipelines as BooPipelines
import BooJs.Compiler.Steps as Steps


def PatchBooPipeline(pipe as CompilerPipeline):

    # TODO: Do we need this?
    pipe.Insert(0, Steps.InitializeEntityNameMatcher())

    # Process safe member access operator
    pipe.InsertAfter(Parsing, Steps.SafeAccess())
    pipe.InsertAfter(Parsing, Steps.ApplyPlaceholderParameters())
    # Make sure the parsing generated AST fits our needs
    pipe.InsertAfter(Parsing, Steps.AdaptParsingAst())

    # Check for unsupported features
    unsupported = Steps.UnsupportedFeatures()
    pipe.InsertAfter(Parsing, unsupported)
    pipe.InsertAfter(MacroAndAttributeExpansion, unsupported)

    if pipe.Find(IntroduceGlobalNamespaces) != -1:
        pipe.Replace(IntroduceGlobalNamespaces, Steps.IntroduceGlobalNamespaces())

    if pipe.Find(ExpandDuckTypedExpressions) != -1:
        pipe.Replace(ExpandDuckTypedExpressions, Steps.ExpandDuckTypedExpressions())
    if pipe.Find(ExpandVarArgsMethodInvocations) != -1:
        pipe.Replace(ExpandVarArgsMethodInvocations, Steps.ExpandVarArgsMethodInvocations())

    # TODO: Not sure we need this. It just seems to convert closure blocks
    #       to compiler generated classes.
    if pipe.Find(ProcessClosures) != -1:
        pipe.Remove(ProcessClosures)

    # TODO: Not sure we need this. The nodes should be already bound to the
    #       correct values, this only seems to be needed to support the
    #       additional instrumentation used by Boo to support callables.
    if pipe.Find(InjectCallableConversions) != -1:
        pipe.Remove(InjectCallableConversions)

    # No need to cache/precompile regexp in Javascript
    if pipe.Find(CacheRegularExpressionsInStaticFields) != -1:
        pipe.Remove(CacheRegularExpressionsInStaticFields)

    # Disable int literals range checks
    if pipe.Find(CheckLiteralValues) != -1:
        pipe.Remove(CheckLiteralValues)

    if pipe.Find(ProcessMethodBodiesWithDuckTyping) != -1:
        # Undo some of the stuff performed by ProcessMethodBodies
        pipe.InsertAfter(ProcessMethodBodiesWithDuckTyping, Steps.UndoProcessMethod())
        # Apply modifications to support method overloading
        pipe.InsertAfter(ProcessMethodBodiesWithDuckTyping, Steps.MethodOverloading())
        # Override some of the stuff in the gigantic ProcessMethodBodies step
        pipe.Replace(ProcessMethodBodiesWithDuckTyping, Steps.OverrideProcessMethodBodies())

    # Customize slicing expressions
    if pipe.Find(ExpandComplexSlicingExpressions) != -1:
        pipe.Replace(ExpandComplexSlicingExpressions, Steps.ExpandComplexSlicingExpressions())

    # Relax boolean conversions
    if pipe.Find(InjectImplicitBooleanConversions) != -1:
        pipe.Replace(InjectImplicitBooleanConversions, Steps.InjectImplicitBooleanConversions())

    # Normalize generator expressions
    #InsertAfter(MacroAndAttributeExpansion, Steps.NormalizeGeneratorExpression())

    # Use our custom generators processing
    if pipe.Find(BranchChecking) != -1:
        pipe.Replace(BranchChecking, Steps.BranchChecking())  # Lift limitation for yield staments in try/except blocks
    if pipe.Find(ProcessGenerators) != -1:
        pipe.Replace(ProcessGenerators, Steps.ProcessGenerators())

    # Normalize literals
    if pipe.Find(NormalizeTypeAndMemberDefinitions) != -1:
        pipe.InsertAfter(NormalizeTypeAndMemberDefinitions, Steps.NormalizeLiterals())

    # Use a custom implementation for iterations
    if pipe.Find(NormalizeIterationStatements) != -1:
        pipe.InsertBefore(NormalizeIterationStatements, Steps.NormalizeLoops())
        pipe.Remove(NormalizeIterationStatements)
    if pipe.Find(OptimizeIterationStatements) != -1:
        pipe.Remove(OptimizeIterationStatements)

    # Simplify the unpack operations
    if pipe.Find(NormalizeStatementModifiers) != -1:
        pipe.InsertAfter(NormalizeStatementModifiers, Steps.NormalizeUnpack())


class Parse(BooPipelines.Parse):
    def constructor():
        PatchBooPipeline(self)

class ExpandMacros(BooPipelines.ExpandMacros):
    def constructor():
        PatchBooPipeline(self)

class ResolveExpressions(BooPipelines.ResolveExpressions):
    def constructor():
        PatchBooPipeline(self)

class Compile(BooPipelines.Compile):
    def constructor():
        PatchBooPipeline(self)

        # Adapt try/except statements
        Add Steps.ProcessTry()

        # Normalize method invocations
        Add Steps.NormalizeMethodInvocation()

        # Normalize closures
        Add Steps.NormalizeClosures()

        Add Steps.NormalizeGeneratorExpression()

        # Support `goto`
        Add Steps.ProcessGoto()

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