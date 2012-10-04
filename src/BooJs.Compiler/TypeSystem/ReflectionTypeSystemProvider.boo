namespace BooJs.Compiler.TypeSystem

import Boo.Lang.Compiler.TypeSystem
import Boo.Lang.Compiler.TypeSystem.Reflection.ExternalType as ExternalType
import Boo.Lang.Compiler.TypeSystem.Reflection.ReflectionTypeSystemProvider as BooProvider

import BooJs.Lang

class ReflectionTypeSystemProvider(BooProvider):
""" Configures the primitive types """

    internal class JsRefType(ExternalType):
    """ Type wrapper for reference types """
         def constructor(provider as ReflectionTypeSystemProvider, type as System.Type):
            super(provider, type)

         override def IsAssignableFrom(other as IType) as bool:
             external = other as ExternalType;
             return external == null or external.ActualType != Types.Void;

    internal class JsValueType(ExternalType):
    """ Type wrapper for value types """
        override IsValueType:
            get: return true

        def constructor(provider as ReflectionTypeSystemProvider, type as System.Type):
            super(provider, type)

        override def IsAssignableFrom(other as IType) as bool:
            # TODO: Properly understand all this and refactor it nicely
            result = super(other)
            return result
            if not result:
                ext = other as ExternalType
                if ext:
                    if ActualType == typeof(Globals.NumberInt):
                        if ext.ActualType in (System.Int16, System.Int32, System.Int64):
                            return true
                    elif ActualType == typeof(Globals.NumberUInt):
                        if ext.ActualType in (System.UInt16, System.UInt32, System.UInt64):
                            return true

            return result



    public static final SharedTypeSystemProvider = ReflectionTypeSystemProvider()

    def constructor():
        # Define the base object type
        #MapTo(System.Object, JsRefType(self, Globals.Object))
        MapTo(Globals.Object, JsRefType(self, Globals.Object))

        # Define duck type
        MapTo(Builtins.Duck, JsRefType(self, Builtins.Duck))

        # Strings are actually mutable
        MapTo(Globals.String, JsRefType(self, Globals.String))

        # Define numbers as value types
        type as object = JsValueType(self, Globals.NumberInt)
        for t in (System.SByte, System.Int16, System.Int32, System.Int64, Globals.NumberInt):
            MapTo(t, type)

        type = JsValueType(self, Globals.NumberUInt)
        for t in (System.Byte, System.UInt16, System.UInt32, System.UInt64, Globals.NumberUInt):
            MapTo(t, type)

        type = JsValueType(self, Globals.NumberDouble)
        for t in (System.Single, System.Double, Globals.NumberDouble):
            MapTo(t, type)

        # Boo's immutable Array and mutable List are converted to a JS mutable array
        type = JsRefType(self, Globals.Array)
        MapTo(Globals.Array, type)
        MapTo(Boo.Lang.List, type)

        MapTo(Globals.RegExp, JsRefType(self, Globals.RegExp))
        MapTo(System.Text.RegularExpressions.Regex, JsRefType(self, Globals.RegExp))


