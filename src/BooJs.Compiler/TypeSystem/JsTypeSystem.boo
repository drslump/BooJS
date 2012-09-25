namespace BooJs.Compiler.TypeSystem

import Boo.Lang.Compiler.TypeSystem
import Boo.Lang.Compiler.TypeSystem.Reflection

import BooJs.Lang as JsLang


class JsReflectionTypeSystemProvider(ReflectionTypeSystemProvider):

    public static final SharedTypeSystemProvider = JsReflectionTypeSystemProvider()

    def constructor():
        ReplaceMapping(System.String, JsLang.String)

        # Boo's immutable Array and muttable List are converted to a JS muttable array
        ReplaceMapping(System.Array, JsLang.Array)
        ReplaceMapping(Boo.Lang.List, JsLang.Array)

        ReplaceMapping(Boo.Lang.Hash, JsLang.Object)
        ReplaceMapping(System.Text.RegularExpressions.Regex, JsLang.RegExp)

    def ReplaceMapping(existing as System.Type, newType as System.Type):
        mapping = Map(newType)
        MapTo(existing, mapping)
        return mapping


class JsTypeSystem(TypeSystemServices):

    override ExceptionType:
        get: return Map(JsLang.Error)

    override protected def PreparePrimitives():
        AddPrimitiveType("void", VoidType)
        AddPrimitiveType("bool", BoolType)

        # The duck type
        AddPrimitiveType("duck", DuckType);

        AddLiteralPrimitiveType("string", Map(JsLang.String))
        #AddPrimitiveType("String", Map(JsLang.String))

        # Use .NET's primary object type
        AddPrimitiveType("object", ObjectType)
        # The JavaScript version uses a capital O
        AddPrimitiveType("Object", Map(JsLang.Object))

        # We just need a few types
        AddPrimitiveType("int", IntType)
        AddPrimitiveType("uint", UIntType)
        AddPrimitiveType("double", DoubleType)
        AddPrimitiveType("Number", Map(JsLang.Number))

        AddPrimitiveType("callable", ICallableType)
        AddPrimitiveType("Function", Map(JsLang.Function))

        # TODO: Handle as a global type
        #AddPrimitiveType("Date", DateTimeType)

    /*
    # We might need to replace more methods to take into account the new types
    new def IsNumberOrBool(type as IType):
        return BoolType == type or IsNumber(type)

    new def IsNumber(type as IType):
        return IsPrimitiveNumber(type) or type == DecimalType

    new def IsPrimitiveNumber(type as IType):
        return IsIntegerNumber(type) or type == DoubleType or type == Map(JsLang.Number)
    */
