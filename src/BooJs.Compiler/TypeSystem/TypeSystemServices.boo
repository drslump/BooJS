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

        LongType = Map(Globals.NumberInt)
        IntType = LongType
        SByteType = LongType
        ShortType = LongType

        ULongType = Map(Globals.NumberUInt)
        UIntType = ULongType
        UShortType = ULongType
        ByteType = ULongType

        DoubleType = Map(Globals.Number)
        SingleType = DoubleType

        # In BooJs arrays are mutable too
        ArrayType = Map(Globals.Array)
        ListType = ArrayType

        RegExpType = Map(Globals.RegExp)

        ICallableType = Map(Builtins.ICallable)

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
