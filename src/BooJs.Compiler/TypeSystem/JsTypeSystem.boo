namespace BooJs.Compiler.TypeSystem

import Boo.Lang.Compiler.Ast
import Boo.Lang.Compiler.TypeSystem
import Boo.Lang.Compiler.TypeSystem.Reflection

import BooJs.Lang as JsLang


class JsReflectionTypeSystemProvider(ReflectionTypeSystemProvider):
""" Configures the primitive types """

    internal class JsRefType(ExternalType):
    """ Type wrapper for reference types """
         def constructor(provider as IReflectionTypeSystemProvider, type as System.Type):
            super(provider, type)

         override def IsAssignableFrom(other as IType) as bool:
             external = other as ExternalType;
             return external == null or external.ActualType != Types.Void;

    internal class JsValueType(ExternalType):
    """ Type wrapper for value types """
        override IsValueType:
            get: return true

        def constructor(provider as IReflectionTypeSystemProvider, type as System.Type):
            super(provider, type)

        override def IsAssignableFrom(other as IType) as bool:
            # TODO: Properly understand all this and refactor it nicely
            result = super(other)
            return result
            if not result:
                ext = other as ExternalType
                if ext:
                    if ActualType == typeof(JsLang.NumberInt):
                        if ext.ActualType in (System.Int16, System.Int32, System.Int64):
                            return true
                    elif ActualType == typeof(JsLang.NumberUInt):
                        if ext.ActualType in (System.UInt16, System.UInt32, System.UInt64):
                            return true

            return result



    public static final SharedTypeSystemProvider = JsReflectionTypeSystemProvider()

    def constructor():
        #ReplaceMapping(System.String, JavaLangString)
        #ReplaceMapping(java.lang.String, JavaLangString)
        #ReplaceMapping(System.MulticastDelegate, Boojay.Lang.MulticastDelegate)
        #ReplaceMapping(Boo.Lang.List, Boojay.Lang.List)
        #ReplaceMapping(Boo.Lang.Hash, Boojay.Lang.Hash)

        # Define the base object type
        #MapTo(System.Object, JsRefType(self, JsLang.Proto))
        MapTo(JsLang.Proto, JsRefType(self, JsLang.Proto))

        # Define duck type
        MapTo(JsLang.Duck, JsRefType(self, JsLang.Duck))

        # Strings are actually mutable
        MapTo(JsLang.String, JsRefType(self, JsLang.String))

        # Define numbers as value types
        type as object = JsValueType(self, JsLang.NumberInt)
        for t in (System.SByte, System.Int16, System.Int32, System.Int64, JsLang.NumberInt):
            MapTo(t, type)

        type = JsValueType(self, JsLang.NumberUInt)
        for t in (System.Byte, System.UInt16, System.UInt32, System.UInt64, JsLang.NumberUInt):
            MapTo(t, type)

        type = JsValueType(self, JsLang.NumberDouble)
        for t in (System.Single, System.Double, JsLang.NumberDouble):
            MapTo(t, type)

        # Boo's immutable Array and mutable List are converted to a JS mutable array
        type = JsRefType(self, JsLang.Array)
        MapTo(JsLang.Array, type)
        MapTo(Boo.Lang.List, type)

        MapTo(JsLang.RegExp, JsRefType(self, JsLang.RegExp))
        MapTo(System.Text.RegularExpressions.Regex, JsRefType(self, JsLang.RegExp))



class JsTypeSystemServices(TypeSystemServices):

    override static ErrorEntity = JsLang.Error

    override ExceptionType:
         get: return Map(JsLang.Error)

    override protected def PreparePrimitives():
        # Setup new defaults for primitive types
        ObjectType = Map(JsLang.Proto)
        StringType = Map(JsLang.String)
        ArrayType = Map(JsLang.Array)
        IntType = Map(JsLang.NumberInt)
        UIntType = Map(JsLang.NumberUInt)
        DoubleType = Map(JsLang.NumberDouble)
        RegExpType = Map(JsLang.RegExp)
        ICallableType = Map(JsLang.Function)
        DuckType = Map(JsLang.Duck)

        RuntimeServicesType = Map(JsLang.Runtime.RuntimeServices)
        BuiltinsType = Map(JsLang.Builtins)


        # Add primitive types
        AddPrimitiveType("void", VoidType)
        AddPrimitiveType("object", ObjectType)
        #AddPrimitiveType("list", ArrayType)
        AddPrimitiveType("callable", ICallableType)
        AddPrimitiveType("duck", DuckType);

        AddLiteralPrimitiveType("bool", BoolType)
        AddLiteralPrimitiveType("int", IntType)
        AddLiteralPrimitiveType("uint", UIntType)
        AddLiteralPrimitiveType("double", DoubleType)
        AddLiteralPrimitiveType("string", StringType)
        AddLiteralPrimitiveType('regex', RegExpType)

    override protected def PrepareBuiltinFunctions():
        AddBuiltin(BuiltinFunction.Len)
        #AddBuiltin(BuiltinFunction.AddressOf);
        #AddBuiltin(BuiltinFunction.Eval);
        #AddBuiltin(BuiltinFunction.Switch);



    /*
    # We might need to replace more methods to take into account the new types
    new def IsNumberOrBool(type as IType):
        return BoolType == type or IsNumber(type)

    new def IsNumber(type as IType):
        return IsPrimitiveNumber(type) or type == DecimalType

    new def IsPrimitiveNumber(type as IType):
        return IsIntegerNumber(type) or type == DoubleType or type == Map(JsLang.Number)
    */
