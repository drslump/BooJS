namespace BooJs.Compiler.TypeSystem

import Boo.Lang.Compiler.TypeSystem
import Boo.Lang.Compiler.TypeSystem.Reflection.ExternalType as ExternalType
import Boo.Lang.Compiler.TypeSystem.Reflection.ReflectionTypeSystemProvider as BooProvider

import BooJs.Lang

class ReflectionProvider(BooProvider):
""" Configures the primitive types """

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
            # TODO: Properly understand all this and refactor it nicely
            result = super(other)
            return result


    public static final SharedTypeSystemProvider = ReflectionProvider()

    def constructor():
        # Define the base object type
        #MapTo(System.Object, JsRefType(self, Globals.Object))
        MapTo(Globals.Object, JsRefType(self, Globals.Object))

        # Define duck type
        MapTo(Builtins.Duck, JsRefType(self, Builtins.Duck))

        # Strings are actually mutable
        MapTo(Globals.String, JsRefType(self, Globals.String))
        MapTo(System.String, JsRefType(self, Globals.String))

        # Booleans are value types
        MapTo(Globals.Boolean, JsValueType(self, Globals.Boolean))
        MapTo(System.Boolean, JsValueType(self, Globals.Boolean))

        # Define numbers as value types
        type as IType = JsValueType(self, Globals.NumberInt)
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
        #type = Core.ArrayType(JsRefType(self, Globals.Array), 1)
        MapTo(Globals.Array, type)
        MapTo(Boo.Lang.List, type)

        type = JsRefType(self, Globals.RegExp)
        MapTo(Globals.RegExp, type)
        MapTo(System.Text.RegularExpressions.Regex, type)


