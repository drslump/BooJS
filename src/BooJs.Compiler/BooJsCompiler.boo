namespace BooJs.Compiler

import System

import Boo.Lang.Environments
import Boo.Lang.Compiler
import Boo.Lang.Compiler.Ast
import Boo.Lang.Compiler.TypeSystem(TypeSystemServices)
import Boo.Lang.Compiler.TypeSystem.Services(DowncastPermissions)

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
    return newBooJsCompiler(Pipelines.SaveJs())

def newBooJsCompiler(pipeline as Boo.Lang.Compiler.CompilerPipeline):
    # Register our custom type system provider
    params = CompilerParameters(BooJsTypeSystem.ReflectionProvider.SharedTypeSystemProvider, false)
    # Setup the environment by setting our customized type system services
    params.Environment = DeferredEnvironment() {
        TypeSystemServices: { BooJsTypeSystem.Services() },
        DowncastPermissions: { BooJsTypeSystem.DowncastPermissions() }
    }

    # Load language runtime assemblies
    params.References.Add(params.LoadAssembly('BooJs.Lang'))
    # Load Boo.Lang.Compiler assembly (needed for Extension attribute???)
    #params.References.Add(params.LoadAssembly('Boo.Lang.Compiler'))

    params.Pipeline = pipeline
    return BooJsCompiler(params)
