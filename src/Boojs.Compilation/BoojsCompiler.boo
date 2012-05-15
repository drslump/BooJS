namespace Boojs.Compiler

import Boo.Lang.Environments
import Boo.Lang.Compiler
import Boo.Lang.Compiler.TypeSystem
import Boojs.Compiler.TypeSystem

def newBoojsCompiler():
    return newBoojsCompiler(BoojsPipelines.ProduceBytecode())

def newBoojayCompiler(pipeline as CompilerPipeline):
    parameters = newBoojsCompilerParameters()
    parameters.Pipeline = pipeline
    return BooCompiler(parameters)

def newBoojsCompilerParameters():
    # TODO: Do we need our custom TypeSystem provider?
    parameters = CompilerParameters(JavaReflectionTypeSystemProvider.SharedTypeSystemProvider, true)
    # TODO: ???
    #parameters.References.Add(typeof(java.lang.Object).Assembly)

    # TODO: Why are we referencing the print macro here? To make them globally available?
    parameters.References.Add(typeof(Boojs.Macros.PrintMacro).Assembly)
    parameters.References.Add(typeof(Boojs.Lang.BuiltinsModule).Assembly)

    # TODO: Do we need this?
    #parameters.Environment = DeferredEnvironment() {
    #    TypeSystemServices: { JsTypeSystem() }
    #}

    return parameters
