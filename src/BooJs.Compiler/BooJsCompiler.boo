namespace Boojs.Compiler

import System
import Boo.Lang.Compiler.Ast

import Boojs.Compiler

class BoojsCompiler:
""" Implements our own compiler façade instead of using the original one.
"""
    [Getter(Parameters)]
    private _parameters as CompilerParameters

    def constructor(params as CompilerParameters):
        _parameters = params

    def Run(unit as CompileUnit):
        if not unit:
            raise ArgumentNullException("compileUnit");
        if not Parameters.Pipeline:
            raise InvalidOperationException(Boo.Lang.Resources.StringResources.BooC_CantRunWithoutPipeline)

        context = CompilerContext(Parameters, unit)
        Parameters.Pipeline.Run(context)
        return context

    def Run():
        return Run(CompileUnit())
        

def newBoojsCompiler():
    return newBoojsCompiler(BoojsPipelines.ProduceJs())

def newBoojsCompiler(pipeline as Boo.Lang.Compiler.CompilerPipeline):
    parameters = newBoojsCompilerParameters()
    parameters.Pipeline = pipeline
    return BoojsCompiler(parameters)

def newBoojsCompilerParameters():
    # TODO: Do we need our custom TypeSystem provider?
    #parameters = CompilerParameters(JavaReflectionTypeSystemProvider.SharedTypeSystemProvider, true)
    parameters = CompilerParameters()
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
