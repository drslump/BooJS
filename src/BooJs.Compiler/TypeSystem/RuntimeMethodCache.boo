# DEPRECATED: this approach never worked. It's not possible to override the original class used
# in ProcessMethodBodies :(

namespace BooJs.Compiler.TypeSystem

import System
import System.Collections.Generic
import System.Reflection

import Boo.Lang.Compiler.Util
import Boo.Lang.Compiler(AbstractCompilerComponent)

import Boo.Lang.Compiler.TypeSystem(IMethod, IMethodBase, IConstructor)
import Boo.Lang.Compiler.TypeSystem.Services.RuntimeMethodCache as BooRuntimeMethodCache

import BooJs.Lang.Runtime.Services as RuntimeServices

class RuntimeMethodCache(AbstractCompilerComponent): #(BooRuntimeMethodCache):

    #RuntimeServices_EqualityOperator as IMethod:
    #    get: return CachedMethod('RuntimeServices_EqualityOperator', {
    #        Methods.Of[of object, object, bool](RuntimeServices.Equality) #as IMethodBase
    #    })
    # HACK: Boo converts property getters to this method name, since we can't overload
    #       non virtual properties we do this to shadow them
    new def get_RuntimeServices_EqualityOperator() as IMethod:
        return CachedMethod('RuntimeServices_EqualityOperator', {
            Methods.Of[of object, object, bool](RuntimeServices.Equality) #as IMethodBase
        })

    RuntimeEquality as IMethod:
        get: return CachedMethod('op_Equality', {
            Methods.Of[of object, object, bool](RuntimeServices.Equality)
        })

    RuntimeEnumerable as IMethod:
        get: return CachedMethod('enumerable', {
            Methods.Of[of object, object*](RuntimeServices.Enumerable)
        })

    Each as IMethod:
        get: return CachedMethod('each', {
            Methods.Of[of object*, ICallable, object](RuntimeServices.Each)
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
