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
    """ Define the ICallable interface
    """
        def Call(args as (Object)) as Object


    class Hash(Object):
    """ Simple hash/dictionary based on Javascript's object
    """
        [Transform( $2.hasOwnProperty($1) )]
        static def op_Member(lhs as object, rhs as Hash) as bool:
            pass
        [Transform( not $2.hasOwnProperty($1) )]
        static def op_NotMember(lhs as object, rhs as Hash) as bool:
            pass

        self[key as string] as object:
            [Transform( $0[$1] )]
            get: pass
            [Transform( $0[$1] = $2 )]
            set: pass

        [Transform( Boo.Hash() )]
        def constructor():
            pass
        [Transform( Boo.Hash($1) )]
        def constructor(items as object*):
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


    [Transform( Boo.ReturnValue )]
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

    static def print(*list as (object)) as void:
        pass

    static def cat(*list as (object)) as (object):
    """ Concatenates the given enumerable arguments """
        pass

    static def join(items as (object), separator as string) as string:
        pass
    static def join(items as (object)) as string:
        pass
    #static def join(items as Array, separator as string) as string:
    #    pass
    #static def join(items as Array) as string:
    #    pass
    static def map(items as (object), callback as callable) as (object):
        pass

    static def reduce[of T](items as (T), callback as callable) as T:
        pass
    static def reduce[of T](items as (T), callback as callable, initial as T) as T:
        pass

    static def zip(*arrays as (object)) as (object):
        pass

    static def reversed(items as (object)) as (object):
        pass
    static def reversed(items as string) as (object):
        pass


    # TODO: The annotation does not work :(
    #[TypeInferenceRule(TypeInferenceRules.ArrayOfTypeReferencedByFirstArgument)]
    #def array(type as System.Type, enumerable as System.Collections.IEnumerable):
    #    pass

    #[TypeInferenceRule(TypeInferenceRules.ArrayOfTypeReferencedByFirstArgument)]
    #def array(type as System.Type, num as int):
    #    pass

    static def array(type as System.Type, enumerable as (object)) as (object): #Array:
        pass
    static def array(type as System.Type, num as int) as (object): #Array
        pass
    static def array(enumerable as (object)) as (object): #Array:
        pass


    # Allows to iterate accesing indices/keys
    static def enumerate(enumerable as (object)) as (object): #Array:
        pass

