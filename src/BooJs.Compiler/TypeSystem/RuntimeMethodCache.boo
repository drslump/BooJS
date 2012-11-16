# DEPRECATED: this approach never worked. It's not possible to override the original class used
# in ProcessMethodBodies :(

namespace BooJs.Compiler.TypeSystem

import System
import System.Collections.Generic
import System.Reflection

import Boo.Lang.Compiler.Util
import Boo.Lang.Compiler(AbstractCompilerComponent)
import Boo.Lang.Compiler.TypeSystem(IMethod, IMethodBase, IConstructor)

import BooJs.Lang(Builtins, Globals, RuntimeServices)

class RuntimeMethodCache(AbstractCompilerComponent):

    RuntimeEquality as IMethod:
        get: return CachedMethod('op_Equality', {
            Methods.Of[of object, object, bool](RuntimeServices.Equality)
        })

    RuntimeEnumerable as IMethod:
        get: return CachedMethod('enumerable', {
            Methods.Of[of object, object*](RuntimeServices.Enumerable)
        })

    Generator as IMethod:
        get: return CachedMethod('generator', {
            Methods.Of[of object, object*](RuntimeServices.Generator)
        })

    Each as IMethod:
        get: return CachedMethod('each', {
            Methods.Of[of object*, ICallable, object](RuntimeServices.Each)
        })

    Eval as IMethod:
        get: return CachedMethod('eval', {
            Methods.Of[of string, object](Globals.eval)
        })

    Range1 as IMethod:
        get: return CachedMethod('range1', {
            Methods.Of[of int, (int)](Builtins.range)
        })
    Range2 as IMethod:
        # TODO: It's not resolving the correct method
        get: return CachedMethod('range2', {
            Methods.Of[of int, int, (int)](Builtins.range)
        })

    # Duck methods

    InvokeBinaryOperator as IMethod:
        get: return CachedMethod('InvokeBinaryOperator', {
            Methods.Of[of string, object, object, object](RuntimeServices.InvokeBinaryOperator)
        })

    InvokeUnaryOperator as IMethod:
        get: return CachedMethod('InvokeUnaryOperator', {
            Methods.Of[of string, object, object](RuntimeServices.InvokeUnaryOperator)
        })


    private _methodCache = Dictionary[of string, IMethodBase](StringComparer.Ordinal)
    def CachedMethod(key as string, producer as callable() as MethodInfo) as IMethod:
        return CachedMethodBase(key, { TypeSystemServices.Map(producer()) })

    def CachedConstructor(key as string, producer as callable() as IMethodBase) as IConstructor:
        return CachedMethodBase(key, producer)

    protected def CachedMethodBase(key as string, producer as callable() as IMethodBase) as IMethodBase:
        method as IMethodBase
        if not _methodCache.TryGetValue(key, method):
            method = producer()
            _methodCache.Add(key, method)
        return method
