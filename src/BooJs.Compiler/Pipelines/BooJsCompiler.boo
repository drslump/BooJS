namespace BooJs.Compiler.Pipelines

from System import InvalidOperationException, ArgumentNullException
from System.Reflection import Assembly
from System.Collections.Generic import HashSet

from Boo.Lang.Environments import DeferredEnvironment, my
from Boo.Lang.Compiler import BooCompiler, CompilerParameters
from Boo.Lang.Compiler.Ast import *
from Boo.Lang.Compiler.Services import UniqueNameProvider
from Boo.Lang.Compiler.TypeSystem import TypeSystemServices
from Boo.Lang.Compiler.TypeSystem.Services import DowncastPermissions, InvocationTypeInferenceRules

from BooJs.Compiler import UniqueNameProvider as JsUniqueNameProvider, CompilerContext, TypeSystem as JsTypeSystem


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
    return newBooJsCompiler(SaveJs())


def newBooJsCompiler(pipeline as Boo.Lang.Compiler.CompilerPipeline):
    # Register our custom type system provider
    params = BooJs.Compiler.CompilerParameters(JsTypeSystem.ReflectionProvider.SharedTypeSystemProvider, false)
    # Setup the environment by setting our customized type system services
    params.Environment = DeferredEnvironment() {
        TypeSystemServices: { JsTypeSystem.TypeSystemServices() },
        DowncastPermissions: { JsTypeSystem.DowncastPermissions() },
        UniqueNameProvider: { JsUniqueNameProvider() },
        InvocationTypeInferenceRules: { JsTypeSystem.InvocationTypeInferenceRules() }
    }

    # When running from a *bundle* (ilrepack, mkbundle, ...) the namespaces may be already loaded
    asm = Assembly.GetExecutingAssembly()
    namespaces = HashSet[of string]()
    for type in asm.GetTypes():
        namespaces.Add(type.Namespace)

    # Load language runtime and pattern matching assemblies by default
    for ns in ('BooJs.Lang', 'Boo.Lang.PatternMatching'):
        if ns not in namespaces:
            params.References.Add(params.LoadAssembly(ns))

    params.Pipeline = pipeline
    return BooJsCompiler(params)
