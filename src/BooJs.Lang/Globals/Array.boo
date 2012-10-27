namespace BooJs.Lang.Globals

import BooJs.Lang.Extensions

#import System.Collections(IList, IEnumerable, ICollection)


import System.Collections(IList, IEnumerable, IEnumerator)
import System.Collections.Generic(IList, IEnumerable, IEnumerator)
import System(Func)


class Array[of T] (Object, IList[of T]): #, IList):

    [Transform( Boo.Array.op_Equality($1, $2) )]
    static def op_Equality(lhs as Array[of T], rhs as Array[of T]) as bool:
        pass
    [Transform( Boo.Array.op_Member($1, $2) )]
    static def op_Member(lhs as Array[of T], rhs as object) as bool:
        pass
    [Transform( not Boo.Array.op_Member($1, $2) )]
    static def op_NotMember(lhs as Array[of T], rhs as object) as bool:
        pass
    [Transform( Boo.Array.op_Addition($1, $2) )]
    static def op_Addition(lhs as Array[of T], rhs as Array[of T]) as Array[of T]:
        pass
    [Transform( Boo.Array.op_Multiply($1, $2) )]
    static def op_Multiply(lhs as Array[of T], rhs as int) as Array[of T]:
        pass

    # Allow assignment from arrays
    static def op_Implicit(rhs as (T)) as Array[of T]:
        pass


    # Implement enumerable interfaces that conflicts
    def IEnumerable.GetEnumerator() as IEnumerator:
        pass
    def GetEnumerator() as IEnumerator[of T]:
        pass


    # Indexer
    self[index as int] as T:
        [Transform( $0[$1] )]
        get: pass
        [Transform( $0[$1] = $2 )]
        set: pass

    /*
    self[index as int] as object:
        get: pass
        set: pass
    */

    public length as uint


    def constructor():
        pass
    def constructor(n as int):
        pass

    # HACK: Emulate multiple params in a Javascript compatible way (up to 3 elements)
    def push(itm as T) as uint:
        pass
    def push(itm1 as T, itm2 as T) as uint:
        pass
    def push(itm1 as T, itm2 as T, itm3 as T) as uint:
        pass

    def pop() as T:
        pass

    def reverse() as Array[of T]:
        pass

    def shift() as T:
        pass

    def sort() as Array[of T]:
        pass
    def sort(comp as callable) as Array[of T]:
        pass

    def splice(index as int, cnt as int, *elems as (T)) as Array[of T]:
        pass
    def splice(index as int, cnt as int) as Array[of T]:
        pass
    def splice(index as int) as Array[of T]:
        pass

    # HACK: Emulate multiple params in a Javascript compatible way (up to 3 elements)
    def unshift(itm1 as T) as uint:
        pass
    def unshift(itm1 as T, itm2 as T) as uint:
        pass
    def unshift(itm1 as T, itm2 as T, itm3 as T) as uint:
        pass

    # HACK: Emulate multiple params in a Javascript compatible way (up to 3 elements)
    def concat(itm1 as Array[of T]) as Array[of T]:
        pass
    def concat(itm1 as Array[of T], itm2 as Array[of T]) as Array[of T]:
        pass
    def concat(itm1 as Array[of T], itm2 as Array[of T], itm3 as Array[of T]) as Array[of T]:
        pass

    def join(sep as string) as string:
        pass

    def slice(start as int, stop as int) as Array[of T]:
        pass

    def slice(start as int) as Array[of T]:
        pass

    def indexOf(itm as T, start as int) as int:
        pass

    def indexOf(itm as T) as int:
        pass

    def lastIndexOf(itm as T, start as int) as int:
        pass

    def lastIndexOf(itm as T) as int:
        pass


    def filter(callback as callable, context as object) as Array[of T]:
        pass
    def filter(callback as callable) as Array[of T]:
        pass

    #def forEach(callback as callable(T), context as object) as void:
    def forEach(callback as Func[of T], context as object) as void:

        pass
    def forEach(callback as callable) as void:
        pass

    def every(callback as callable, context as object) as bool:
        pass
    def every(callback as callable) as bool:
        pass

    def map(callback as callable, context as object) as Array[of T]:
        pass
    def map(callback as callable) as Array[of T]:
        pass

    def some(callback as callable, context as object) as bool:
        pass
    def some(callback as callable) as bool:
        pass

    def reduce(callback as callable, initialValue as object) as object:
        pass
    def reduce(callback as callable) as object:
        pass

    def reduceRight(callback as callable, initialValue as object) as object:
        pass
    def reduceRight(callback as callable) as object:
        pass


    # Ecma 5th edition

    static def isArray(arg as object) as bool:
        pass



class Array(Array[of object]):
    def constructor():
        pass
    def constructor(n as int):
        pass
