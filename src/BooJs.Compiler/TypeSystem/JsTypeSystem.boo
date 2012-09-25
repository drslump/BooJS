namespace BooJs.Compiler.TypeSystem

import Boo.Lang.Compiler.TypeSystem
import Boo.Lang.Compiler.TypeSystem.Reflection

import BooJs.Lang as JsLang


class JsReflectionTypeSystemProvider(ReflectionTypeSystemProvider):

    public static final SharedTypeSystemProvider = JsReflectionTypeSystemProvider()

    def constructor():
        # Define the base object type
        MapTo(JsLang.Proto, JsObjectType(self, JsLang.Proto))

        # Javascript's strings are mutable
        MapTo(JsLang.String, JsObjectType(self, JsLang.String))

        # Define numbers as value types
        MapTo(JsLang.NumberInt, JsValueType(self, JsLang.NumberInt))
        MapTo(JsLang.NumberUInt, JsValueType(self, JsLang.NumberUInt))
        MapTo(JsLang.NumberDouble, JsValueType(self, JsLang.NumberDouble))



        # Boo's immutable Array and muttable List are converted to a JS muttable array
        ReplaceMapping(System.Array, JsLang.Array)
        ReplaceMapping(Boo.Lang.List, JsLang.Array)

        ReplaceMapping(System.Text.RegularExpressions.Regex, JsLang.RegExp)

    def ReplaceMapping(existing as System.Type, newType as System.Type):
        mapping = Map(newType)
        MapTo(existing, mapping)
        return mapping


class JsObjectType(ExternalType):
     def constructor(provider as IReflectionTypeSystemProvider, type as System.Type):
        super(provider, type)

     override def IsAssignableFrom(other as IType) as bool:
         external = other as ExternalType;
         return external == null or external.ActualType != Types.Void;

class JsValueType(ExternalType):
    override IsValueType:
        get: return true

    def constructor(provider as IReflectionTypeSystemProvider, type as System.Type):
        super(provider, type)



class JsTypeSystem(TypeSystemServices):

    override static ErrorEntity = JsLang.Error

    override ExceptionType:
         get: return Map(JsLang.Error)

    override protected def PreparePrimitives():
        ObjectType = Map(JsLang.Proto)
        StringType = Map(JsLang.String)
        ArrayType = Map(JsLang.Array)
        IntType = Map(JsLang.NumberInt)
        UIntType = Map(JsLang.NumberUInt)
        DoubleType = Map(JsLang.NumberDouble)
        RegExpType = Map(JsLang.RegExp)
        ICallableType = Map(JsLang.Function)

        AddPrimitiveType("void", VoidType)
        AddPrimitiveType("duck", DuckType);
        AddPrimitiveType("object", ObjectType)
        AddPrimitiveType("array", ArrayType)
        AddPrimitiveType("callable", ICallableType)

        # We just need a few types
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
