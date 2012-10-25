namespace BooJs.Compiler.TypeSystem

import Boo.Lang.Compiler.TypeSystem(BuiltinFunction, IType)
import Boo.Lang.Compiler.TypeSystem.TypeSystemServices as BooServices

import BooJs.Lang(Globals, Builtins, Runtime)


class Services(BooServices):

    override static ErrorEntity = Globals.Error

    override ExceptionType:
         get: return Map(Globals.Error)

    override protected def PreparePrimitives():
        # Setup new defaults for primitive types
        ObjectType = Map(Globals.Object)
        ObjectArrayType = ObjectType.MakeArrayType(1)

        StringType = Map(Globals.String)

        BoolType = Map(Globals.Boolean)

        SByteType = Map(Globals.NumberInt)
        ShortType = Map(Globals.NumberInt)
        IntType = Map(Globals.NumberInt)
        LongType = Map(Globals.NumberInt)

        ByteType = Map(Globals.NumberUInt)
        UShortType = Map(Globals.NumberUInt)
        UIntType = Map(Globals.NumberUInt)
        ULongType = Map(Globals.NumberUInt)

        SingleType = Map(Globals.Number)
        DoubleType = Map(Globals.Number)

        # In BooJs arrays are mutable too
        ArrayType = Map(Globals.Array)
        ListType = Map(Globals.Array)

        RegExpType = Map(Globals.RegExp)

        #ICallableType = Map(Builtins.ICallable)

        DuckType = Map(Builtins.Duck)

        RuntimeServicesType = Map(Runtime.Services)
        BuiltinsType = Map(Builtins)


        # Add primitive types
        AddPrimitiveType("void", VoidType)
        AddPrimitiveType("object", ObjectType)
        AddPrimitiveType("callable", ICallableType)
        AddPrimitiveType("duck", DuckType)

        AddLiteralPrimitiveType("bool", BoolType)
        AddLiteralPrimitiveType("int", LongType)
        AddLiteralPrimitiveType("uint", ULongType)
        AddLiteralPrimitiveType("double", DoubleType)
        AddLiteralPrimitiveType("string", StringType)
        AddLiteralPrimitiveType('regex', RegExpType)

    override protected def PrepareBuiltinFunctions():
        AddBuiltin(BuiltinFunction.Len)
        AddBuiltin(BuiltinFunction.Eval);
        #AddBuiltin(BuiltinFunction.AddressOf);
        #AddBuiltin(BuiltinFunction.Switch);


    /*
    # We might need to replace more methods to take into account the new types
    new def IsNumberOrBool(type as IType):
        return BoolType == type or IsNumber(type)

    new def IsNumber(type as IType):
        return IsPrimitiveNumber(type) or type == DecimalType

    new def IsPrimitiveNumber(type as IType):
        return IsIntegerNumber(type) or type == DoubleType or type == Map(Globals.Number)
    */
