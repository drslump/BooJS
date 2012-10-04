namespace BooJs.Compiler.TypeSystem

import Boo.Lang.Compiler.TypeSystem(BuiltinFunction)
import Boo.Lang.Compiler.TypeSystem.TypeSystemServices as BooServices

import BooJs.Lang


class TypeSystemServices(BooServices):

    override static ErrorEntity = Globals.Error

    override ExceptionType:
         get: return Map(Globals.Error)

    override protected def PreparePrimitives():
        # Setup new defaults for primitive types
        ObjectType = Map(Globals.Object)
        StringType = Map(Globals.String)
        ArrayType = Map(Globals.Array)
        IntType = Map(Globals.NumberInt)
        UIntType = Map(Globals.NumberUInt)
        DoubleType = Map(Globals.NumberDouble)
        RegExpType = Map(Globals.RegExp)
        ICallableType = Map(Globals.Function)
        DuckType = Map(Builtins.Duck)

        RuntimeServicesType = Map(Runtime.RuntimeServices)
        BuiltinsType = Map(Builtins)


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
        return IsIntegerNumber(type) or type == DoubleType or type == Map(Globals.Number)
    */
