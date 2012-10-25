namespace BooJs.Compiler.TypeSystem

import Boo.Lang.Compiler.TypeSystem
import Boo.Lang.Compiler.TypeSystem.Reflection.ExternalType as ExternalType
import Boo.Lang.Compiler.TypeSystem.Reflection(IReflectionTypeSystemProvider, IAssemblyReference)
import Boo.Lang.Compiler.TypeSystem.Reflection.ReflectionTypeSystemProvider as BooProvider

import BooJs.Lang

/*
import System
import System.Collections.Generic
import System.Reflection
import Boo.Lang.Compiler.Util
*/

class ReflectionProvider(BooProvider): #IReflectionTypeSystemProvider):
""" Tells the compiler how it should interpret reflected types """

    internal class JsRefType(ExternalType):
    """ Type wrapper for reference types """
         def constructor(provider as ReflectionProvider, type as System.Type):
            super(provider, type)

         override def IsAssignableFrom(other as IType) as bool:
             external = other as ExternalType;
             return true if external is null
             return true if external is other
             return true if external.IsAssignableFrom(other)
             return external.ActualType != Types.Void;

    internal class JsValueType(ExternalType):
    """ Type wrapper for value types """
        override IsValueType:
            get: return true

        def constructor(provider as ReflectionProvider, type as System.Type):
            super(provider, type)

        override def IsAssignableFrom(other as IType) as bool:
            result = super(other)
            return result


    public static final SharedTypeSystemProvider = ReflectionProvider()

    def constructor():

        # TODO: Not sure we need to map all types
        # Define the base object type
        reftype = JsRefType(self, Globals.Object)
        MapTo(Globals.Object, reftype)

        # Define duck type
        reftype = JsRefType(self, Builtins.Duck)
        MapTo(Builtins.Duck, reftype)

        # Define ICallable type
        reftype = JsRefType(self, Builtins.ICallable)
        MapTo(typeof(callable), reftype)
        MapTo(Builtins.ICallable, reftype)

        # Strings (which are actually mutable)
        reftype = JsRefType(self, Globals.String)
        MapTo(typeof(string), reftype)
        MapTo(Globals.String, reftype)

        # Booleans are value types
        valtype = JsValueType(self, Globals.Boolean)
        MapTo(typeof(bool), valtype)
        MapTo(Globals.Boolean, valtype)

        # Define numbers as value types
        valtype = JsValueType(self, Globals.NumberInt)
        MapTo(typeof(sbyte), valtype)
        MapTo(typeof(short), valtype)
        MapTo(typeof(int), valtype)
        MapTo(typeof(long), valtype)
        MapTo(Globals.NumberInt, valtype)

        valtype = JsValueType(self, Globals.NumberUInt)
        MapTo(typeof(byte), valtype)
        MapTo(typeof(ushort), valtype)
        MapTo(typeof(uint), valtype)
        MapTo(typeof(ulong), valtype)
        MapTo(Globals.NumberUInt, valtype)

        valtype = JsValueType(self, Globals.Number)
        MapTo(typeof(single), valtype)
        MapTo(typeof(double), valtype)
        MapTo(Globals.Number, valtype)

        # Lists and Hashes
        reftype = JsRefType(self, Globals.Array)
        MapTo(Boo.Lang.List, reftype)
        MapTo(Globals.Array, reftype)

        reftype = JsRefType(self, Builtins.Hash)
        MapTo(Boo.Lang.Hash, reftype)
        MapTo(Builtins.Hash, reftype)

        reftype = JsRefType(self, Globals.RegExp)
        MapTo(typeof(regex), reftype)
        MapTo(Globals.RegExp, reftype)


    override def CreateEntityForRegularType(type as System.Type):
        if type.IsValueType:
            return JsValueType(self, type)
        else:
            return JsRefType(self, type)

