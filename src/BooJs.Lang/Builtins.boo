namespace BooJs.Lang

import BooJs.Lang.Globals
import BooJs.Lang.Extensions


class Builtins:

    [Transform( '%%COMPILER_VERSION%%' )]
    static public final BOO_COMPILER_VERSION = '%%COMPILER_VERSION%%'
    static public final BOO_RUNTIME_VERSION = 'defined in boo.js'

    static public final STOP = 'STOP'




    class Duck(Object, Boo.Lang.IQuackFu):
    """ Implementes the IQuackFu interface
    """
        def QuackGet(name as string, params as (object)) as object:
            pass

        def QuackSet(name as string, params as (object), value as object) as object:
            pass

        def QuackInvoke(name as string, args as (object)) as object:
            pass


    interface ICallable:
    """ Custom ICallable interface using our Object type
    """
        def Call(args as (Object)) as Object


    [EnumeratorItemType(typeof(Object))]
    class Hash(Object, Iterable, IQuackFu):  # The IQuackFoo allows to access items as members (dot notation)
    """ Simple hash/dictionary based on Javascript's object
    """
        [Transform( $2.hasOwnProperty($1) )]
        static def op_Member(lhs as object, rhs as Hash) as bool:
            pass
        [Transform( not $2.hasOwnProperty($1) )]
        static def op_NotMember(lhs as object, rhs as Hash) as bool:
            pass

        self[key as object] as object:
            [Transform( $0[$1] )]
            get: pass
            [Transform( $0[$1] = $2 )]
            set: pass

        [Transform( Boo.Hash() )]
        def constructor():
            pass
        [Transform( Boo.Hash($1) )]
        def constructor(items as Iterable):
            pass

        # Use a transform to ensure we can use it with plain object literals too
        [Transform( Boo.Hash.keys($0) )]
        def keys() as (string):
            pass
        [Transform( Boo.Hash.values($0) )]
        def values() as (object):
            pass
        [Transform( Boo.enumerate($0) )]
        def items() as ((object)):
            pass


    class AssertionError(Error):
    """ BooJs specific error to signal failures in assertions
    """
        def constructor():
            pass
        def constructor(msg as string):
            pass


    class ReturnValue:
        public value as object

        def constructor(val as object):
            value = val


    static def range(stop as int) as (int):
        pass
    static def range(start as int, stop as int) as (int):
        pass
    static def range(start as int, stop as int, step as int) as (int):
        pass
    [Transform( Boo.range($1) )]
    static def xrange(stop as int) as Iterable[of int]:
        pass
    [Transform( Boo.range($1, $2) )]
    static def xrange(start as int, stop as int) as Iterable[of int]:
        pass
    [Transform( Boo.range($1, $2, $3) )]
    static def xrange(start as int, stop as int, step as int) as Iterable[of int]:
        pass

    static def print(*list as (object)) as void:
        pass

    #static def cat(*list as (object)) as (object):
    static def cat(*list as (object)) as Array:
    """ Concatenates the given enumerable arguments """
        pass

    static def join[of T](items as Iterable[of T], separator as String) as String:
        pass
    static def join[of T](items as Iterable[of T]) as String:
        pass
    static def join(items as Array, separator as String) as String:
        pass
    static def join(items as Array) as String:
        pass

    #static def map(items as object*, callback as callable(object)) as object*:
    static def map(items as Array, callback as callable(object)) as Array:
        pass

    static def reduce[of T](items as (T), callback as callable) as T:
        pass
    static def reduce[of T](items as (T), callback as callable, initial as T) as T:
        pass

    static def filter(items as (object), callback as callable) as (object):
        pass

    static def zip(*arrays as (object)) as (object):
        pass

    static def reversed(items as String) as Array:
        pass
    static def reversed(items as Array) as Array:
        pass
    static def reversed[of T](items as Iterable[of T]) as Array[of T]:
        pass


    [TypeInferenceRule(TypeInferenceRules.ArrayOfTypeReferencedByFirstArgument)]
    static def array(type as System.Type, enumerable as Iterable) as Array:
        pass
    [TypeInferenceRule(TypeInferenceRules.ArrayOfTypeReferencedByFirstArgument)]
    static def array(type as System.Type, num as int) as Array:
        pass
    [TypeInferenceRule(TypeInferenceRules.TypeOfFirstArgument)]
    static def array(enumerable as Iterable) as (object):
        pass
    static def array[of T](enumerable as Iterable[of T]) as (T):
        pass


    # Allows to iterate accesing indices/keys
    static def enumerate(enumerable as Iterable) as ((object)):
        pass
