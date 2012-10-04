namespace BooJs.Compiler

import System

import Boo.Lang.Environments
import Boo.Lang.Compiler
import Boo.Lang.Compiler.TypeSystem
import Boo.Lang.Compiler.Ast

import BooJs.Compiler.TypeSystem as BooJsTypeSystem


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
    # Register our custom type system provider
    params = CompilerParameters(BooJsTypeSystem.ReflectionProvider.SharedTypeSystemProvider)

    # Load language runtime assemblies
    params.References.Add(params.LoadAssembly('BooJs.Lang'))
    # Load Boo.Lang.Compiler assembly (needed for Extension attribute for example)
    params.References.Add(params.LoadAssembly('Boo.Lang.Compiler'))

    # Setup the environment by setting our customized type system services
    params.Environment = DeferredEnvironment() {
        TypeSystemServices: { BooJsTypeSystem.Services() }
    }

    return params
