namespace BooJs.Compiler

import System

import Boo.Lang.Environments
import Boo.Lang.Compiler
import Boo.Lang.Compiler.Ast
import Boo.Lang.Compiler.TypeSystem(TypeSystemServices)
import Boo.Lang.Compiler.TypeSystem.Services(DowncastPermissions)

import BooJs.Compiler.TypeSystem as BooJsTypeSystem


class BooJsCompiler(BooCompiler):
""" Implements our own compiler façade instead of using the original one.
"""
    def constructor(params as CompilerParameters):
        super(params)

    new def Run(unit as CompileUnit):
        if not unit:
            raise ArgumentNullException("compileUnit");
        if not Parameters.Pipeline:
            raise InvalidOperationException(Boo.Lang.Resources.StringResources.BooC_CantRunWithoutPipeline)

        ctxt = CompilerContext(Parameters, unit)
        Parameters.Pipeline.Run(ctxt)

        return ctxt

    new def Run():
        return Run(CompileUnit())
        

def newBooJsCompiler():
    return newBooJsCompiler(Pipelines.SaveJs())

def newBooJsCompiler(pipeline as Boo.Lang.Compiler.CompilerPipeline):
    # Register our custom type system provider
    params = CompilerParameters(BooJsTypeSystem.ReflectionProvider.SharedTypeSystemProvider, false)
    # Setup the environment by setting our customized type system services
    params.Environment = DeferredEnvironment() {
        TypeSystemServices: { BooJsTypeSystem.TypeSystemServices() },
        DowncastPermissions: { BooJsTypeSystem.DowncastPermissions() }
    }

    # Load language runtime assemblies
    params.References.Add(params.LoadAssembly('BooJs.Lang'))
    # Load Boo.Lang.PatternMatching assembly (we provide access to it by default)
    params.References.Add(params.LoadAssembly('Boo.Lang.PatternMatching'))

    params.Pipeline = pipeline
    return BooJsCompiler(params)
