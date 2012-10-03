namespace BooJs.Compiler.TypeSystem

import Boo.Lang.Compiler.TypeSystem
import Boo.Lang.Compiler.TypeSystem.Reflection

import BooJs.Lang as JsLang


class JsReflectionTypeSystemProvider(ReflectionTypeSystemProvider):
""" Configures the primitive types """

    class JsObjectType(ExternalType):
    """ Type wrapper for reference types """
         def constructor(provider as IReflectionTypeSystemProvider, type as System.Type):
            super(provider, type)

         override def IsAssignableFrom(other as IType) as bool:
             external = other as ExternalType;
             return external == null or external.ActualType != Types.Void;

    class JsValueType(ExternalType):
    """ Type wrapper for value types """
        override IsValueType:
            get: return true

        def constructor(provider as IReflectionTypeSystemProvider, type as System.Type):
            super(provider, type)

    public static final SharedTypeSystemProvider = JsReflectionTypeSystemProvider()

    def constructor():
        # Define the base object type
        MapTo(JsLang.Proto, JsObjectType(self, JsLang.Proto))

        # Define duck type
        MapTo(JsLang.Duck, JsObjectType(self, JsLang.Duck))

        # Strings are actually mutable
        MapTo(JsLang.String, JsObjectType(self, JsLang.String))

        # Define numbers as value types
        MapTo(JsLang.NumberInt, JsValueType(self, JsLang.NumberInt))
        MapTo(JsLang.NumberUInt, JsValueType(self, JsLang.NumberUInt))
        MapTo(JsLang.NumberDouble, JsValueType(self, JsLang.NumberDouble))

        # Boo's immutable Array and mutable List are converted to a JS mutable array
        MapTo(JsLang.Array, JsObjectType(self, JsLang.Array))
        MapTo(Boo.Lang.List, JsObjectType(self, JsLang.Array))

        MapTo(JsLang.RegExp, JsObjectType(self, JsLang.RegExp))
        MapTo(System.Text.RegularExpressions.Regex, JsObjectType(self, JsLang.RegExp))



class JsTypeSystem(TypeSystemServices):

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

        # Add primitive types
        AddPrimitiveType("void", VoidType)
        AddPrimitiveType("duck", DuckType);
        AddPrimitiveType("object", ObjectType)
        AddPrimitiveType("list", ArrayType)
        AddPrimitiveType("callable", ICallableType)

        AddLiteralPrimitiveType("bool", BoolType)
        AddLiteralPrimitiveType("int", IntType)
        AddLiteralPrimitiveType("uint", UIntType)
        AddLiteralPrimitiveType("double", DoubleType)
        AddLiteralPrimitiveType("string", StringType)
        AddLiteralPrimitiveType('regex', RegExpType)

        # TODO: Handle as a global type
        #AddPrimitiveType("Date", DateTimeType)

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
