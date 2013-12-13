namespace BooJs.Compiler.TypeSystem

from System.Collections.Generic import ICollection
from Boo.Lang.Environments import my
from Boo.Lang.Compiler.TypeSystem.Services import NameResolutionService
from Boo.Lang.Compiler.TypeSystem import IType, Types, IEntity, EntityType
from Boo.Lang.Compiler.TypeSystem.Reflection import ExternalType, ReflectionTypeSystemProvider as BooProvider
from BooJs.Lang import Globals, Builtins


class ReflectionProvider(BooProvider):
""" Tells the compiler how it should interpret reflected types """

    internal class JsRefType(ExternalType):
    """ Type wrapper for reference types """
        def constructor(provider as ReflectionProvider, type as System.Type):
            super(provider, type)

        override def IsAssignableFrom(other as IType) as bool:
            external = other as ExternalType

            # Globals.Object behaves just like System.Object
            # TODO: This shouldn't be needed if/when we can map System.Object
            # if self.ActualType in (System.Object, Globals.Object, Builtins.Duck):
            #    return external is null or external.ActualType != Types.Void

            result = super(other)

            if not result:
                # TODO: Iterable[of int] is currently assignable for Array[of string]
                tss = Boo.Lang.Environments.my(TypeSystemServices)
                aoftype = tss.Map(typeof(Globals.Array[of*]))
                if self == tss.ArrayType:
                    # Array <- Array[of *]
                    return true if other == aoftype
                    # Array <- Array[of T]
                    return true if other.ConstructedInfo and other.ConstructedInfo.GenericDefinition == aoftype

            return result


    internal class JsObjectType(ExternalType):

        override BaseType as IType:
            get: return null

        def constructor(provider as ReflectionProvider, type as System.Type):
            super(provider, type)

        override def IsAssignableFrom(other as IType) as bool:
            external = other as ExternalType
            return external == null or external.ActualType != Types.Void

        override def IsSubclassOf(other as IType) as bool:
            return false

        override def Resolve(resultingSet as ICollection[of IEntity], name as string, typesToConsider as EntityType) as bool:
            result = my(NameResolutionService).Resolve(name, GetMembers(), typesToConsider, resultingSet)
            return result


    internal class JsValueType(ExternalType):
    """ Type wrapper for value types """
        override IsValueType:
            get: return true

        def constructor(provider as ReflectionProvider, type as System.Type):
            super(provider, type)

        override def IsAssignableFrom(other as IType) as bool:
            result = super(other)
            return result


    internal class JsVoidType(ExternalType):

        def constructor(provider as ReflectionProvider):
            super(provider, Types.Void)

        override def Resolve(resultingSet as ICollection[of IEntity], name as string, typesToConsider as EntityType) as bool:
            return false

        override def IsSubclassOf(other as IType) as bool:
            return false

        override def IsAssignableFrom(other as IType) as bool:
            return false


    public static final SharedTypeSystemProvider = ReflectionProvider()

    
    override protected def Initialize():

        #super()

        # Define the base object type
        # Work around: Keep System.Object mapped like in Boo, actually it
        #              should only matter when referenced Types are compiled
        #              with standard Boo.
        #              Include a new compilation mode for BooJs (--typedef)
        #              that generates a plain .Net assembly with the type
        #              definitions, with System.Object being substituted by
        #              Global.Object. It can be used to compile External
        #              definitions, so in essence, BooJs users won't ever have
        #              to work with native .Net types.
        
        objtype = JsObjectType(self, Globals.Object)
        # MapTo(typeof(object), JsObjectType(self, System.Object))
        MapTo(System.Object, objtype)
        MapTo(Globals.Object, objtype)

        MapTo(typeof(void), JsVoidType(self))

        # Define duck type
        objtype = JsObjectType(self, Builtins.Duck)
        # TODO: typeof(duck) seems to be the same as typeof(object)
        # MapTo(typeof(duck), objtype)
        MapTo(Builtins.Duck, objtype)

        # Define ICallable type
        reftype = JsRefType(self, Builtins.ICallable)
        MapTo(typeof(callable), reftype)
        MapTo(Builtins.ICallable, reftype)

        # Strings (which are actually mutable)
        reftype = JsRefType(self, Globals.String)
        MapTo(typeof(string), reftype)
        MapTo(Globals.String, reftype)

        # Booleans are value types
        valtype = JsValueType(self, Globals.Boolean)
        MapTo(typeof(bool), valtype)
        MapTo(Globals.Boolean, valtype)

        # Define numbers as value types
        valtype = JsValueType(self, Globals.NumberInt)
        MapTo(typeof(sbyte), valtype)
        MapTo(typeof(short), valtype)
        MapTo(typeof(int), valtype)
        MapTo(typeof(long), valtype)
        MapTo(Globals.NumberInt, valtype)

        valtype = JsValueType(self, Globals.NumberUInt)
        MapTo(typeof(byte), valtype)
        MapTo(typeof(ushort), valtype)
        MapTo(typeof(uint), valtype)
        MapTo(typeof(ulong), valtype)
        MapTo(Globals.NumberUInt, valtype)

        valtype = JsValueType(self, Globals.Number)
        MapTo(typeof(single), valtype)
        MapTo(typeof(double), valtype)
        MapTo(Globals.Number, valtype)

        # Lists and Hashes
        reftype = JsRefType(self, Globals.Array)
        MapTo(System.Array, reftype)
        MapTo(Globals.Array, reftype)

        reftype = JsRefType(self, typeof(Globals.Array[of*]))
        MapTo(typeof(Boo.Lang.List), reftype)
        MapTo(typeof(Boo.Lang.List[of*]), reftype)
        MapTo(typeof(Globals.Array[of*]), reftype)

        reftype = JsRefType(self, typeof(Globals.Iterable))
        MapTo(System.Collections.IEnumerable, reftype)
        MapTo(Globals.Iterable, reftype)

        reftype = JsRefType(self, typeof(Globals.Iterable[of*]))
        MapTo(typeof(System.Collections.Generic.IEnumerable[of*]), reftype)
        MapTo(typeof(Globals.Iterable[of*]), reftype)

        # Map some common enumerable generic types
        # TODO: Must be a more elegant way to do this
        /*
        reftype = JsRefType(self, typeof(Globals.IEnumerable[of object]))
        MapTo(System.Collections.Generic.IEnumerable[of object], reftype)
        MapTo(Globals.IEnumerable[of object], reftype)

        reftype = JsRefType(self, typeof(Globals.IEnumerable[of Globals.NumberInt]))
        MapTo(System.Collections.Generic.IEnumerable[of int], reftype)
        MapTo(Globals.IEnumerable[of Globals.NumberInt], reftype)

        reftype = JsRefType(self, typeof(Globals.IEnumerable[of string]))
        MapTo(System.Collections.Generic.IEnumerable[of string], reftype)
        MapTo(Globals.IEnumerable[of string], reftype)
        */

        reftype = JsRefType(self, Builtins.Hash)
        MapTo(Boo.Lang.Hash, reftype)
        MapTo(Builtins.Hash, reftype)

        reftype = JsRefType(self, Globals.RegExp)
        MapTo(typeof(regex), reftype)
        MapTo(Globals.RegExp, reftype)


    override def CreateEntityForRegularType(type as System.Type):
        if type.IsValueType:
            return JsValueType(self, type)
        else:
            return JsRefType(self, type)
