namespace BooJs.Compiler

import System

import Boo.Lang.Environments
import Boo.Lang.Compiler
import Boo.Lang.Compiler.TypeSystem
import Boo.Lang.Compiler.Ast

import BooJs.Compiler.TypeSystem


class BooJsCompiler:
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
        

def newBooJsCompiler():
    return newBooJsCompiler(Pipelines.ProduceBooJs())

def newBooJsCompiler(pipeline as Boo.Lang.Compiler.CompilerPipeline):
    parameters = newBooJsCompilerParameters()
    parameters.Pipeline = pipeline
    return BooJsCompiler(parameters)

def newBooJsCompilerParameters():
    # TODO: Do we need our custom TypeSystem provider?
    #parameters = CompilerParameters()
    parameters = CompilerParameters(JsReflectionTypeSystemProvider.SharedTypeSystemProvider) #, true)

    # TODO: ???
    #parameters.References.Add(typeof(java.lang.Object).Assembly)

    # TODO: Why are we referencing the print macro here? To make them globally available?
    parameters.References.Add(typeof(BooJs.Macros.PrintMacro).Assembly)
    parameters.References.Add(typeof(BooJs.Lang.BuiltinsModule).Assembly)

    # TODO: Do we need this?
    parameters.Environment = DeferredEnvironment() {
        TypeSystemServices: { JsTypeSystem() }
    }

    return parameters
