namespace BooJs.Compiler.TypeSystem

from Boo.Lang.Compiler.TypeSystem import BuiltinFunction, IType, TypeSystemServices as BooServices

from BooJs.Lang import Globals, Builtins, RuntimeServices


class TypeSystemServices(BooServices):

    override static ErrorEntity = Globals.Error

    public IGeneratorType as IType
    public IGeneratorGenericType as IType

    override ExceptionType:
         get: return Map(Globals.Error)

    override protected def PreparePrimitives():
        # Setup new defaults for primitive types
        ObjectType = Map(Globals.Object)
        ObjectArrayType = ObjectType.MakeArrayType(1)

        StringType = Map(Globals.String)
        CharType = StringType  # We handle chars as strings

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
        ArrayType = Map(typeof(Globals.Array))
        ListType = ArrayType
        # List is implemented with a generic version of Array
        #ListType = Map(typeof(Globals.Array[of Globals.Object]))

        HashType = Map(Builtins.Hash)

        # Enumerables
        IEnumerableType = Map(typeof(Globals.Iterable))
        IEnumerableGenericType = Map(typeof(Globals.Iterable[of*]))

        # Custom generator type
        IGeneratorType = Map(typeof(Globals.GeneratorIterator))
        IGeneratorGenericType = Map(typeof(Globals.GeneratorIterator[of*]))

        RegExpType = Map(Globals.RegExp)

        ICallableType = Map(Builtins.ICallable)

        DuckType = Map(Builtins.Duck)

        RuntimeServicesType = Map(RuntimeServices)
        BuiltinsType = Map(Builtins)


        # Add primitive types
        AddPrimitiveType("void", VoidType)
        AddPrimitiveType("object", ObjectType)
        AddPrimitiveType("callable", ICallableType)
        AddPrimitiveType("duck", DuckType)
        # Make TypeScript folks feel more at home :)
        AddPrimitiveType("any", DuckType)

        AddLiteralPrimitiveType("bool", BoolType)
        AddLiteralPrimitiveType("int", LongType)
        AddLiteralPrimitiveType("uint", ULongType)
        AddLiteralPrimitiveType("double", DoubleType)
        AddLiteralPrimitiveType("string", StringType)
        AddLiteralPrimitiveType('regex', RegExpType)

    override protected def PrepareBuiltinFunctions():
        AddBuiltin(BuiltinFunction.Len)
        AddBuiltin(BuiltinFunction.Eval);

    override public def CanBeReachedByPromotion(expectedType as IType, actualType as IType) as bool:
        # Boo allows to cast chars to integers, since in BooJs a char is just a string
        # we can't allow that kind of cast.
        if IsIntegerNumber(actualType) and expectedType == CharType:
            return false
        if IsIntegerNumber(expectedType) and actualType == CharType:
            return false

        return super(expectedType, actualType)

     new def IsSystemObject(type as IType):
        # ObjectType is mapped to our custom object so we have to check also against System.Object
        return super.IsSystemObject(type) or type is Map(System.Object)

     new def IsDuckType(type as IType) as bool:
        # ObjectType is mapped to our custom object so we have to check also against System.Object
        return super.IsDuckType(type) or (Context.Parameters.Ducky and IsSystemObject(type))

     override def IsDuckTyped(node as Boo.Lang.Compiler.Ast.Expression) as bool:
        type = node.ExpressionType
        return type is not null and IsDuckType(type)



