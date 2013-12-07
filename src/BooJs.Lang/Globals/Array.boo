namespace BooJs.Lang.Globals

from System import Func
from BooJs.Lang.Extensions import TransformAttribute, VarArgsAttribute


class Array[of T] (Object, Iterable[of T]):

    [Transform( Boo.Array.op_Equality($1, $2) )]
    static def op_Equality(lhs as Array[of T], rhs as Array[of T]) as bool:
        pass
    [Transform( Boo.Array.op_Equality($1, $2) )]
    static def op_Equality(lhs as Array[of T], rhs as Array) as bool:
        pass
    [Transform( Boo.Array.op_Member($1, $2) )]
    static def op_Member(lhs as object, rhs as Array[of T]) as bool:
        pass
    [Transform( not Boo.Array.op_Member($1, $2) )]
    static def op_NotMember(lhs as object, rhs as Array[of T]) as bool:
        pass
    [Transform( Boo.Array.op_Addition($1, $2) )]
    static def op_Addition(lhs as Array[of T], rhs as Array[of T]) as Array[of T]:
        pass
    [Transform( Boo.Array.op_Multiply($1, $2) )]
    static def op_Multiply(lhs as Array[of T], rhs as int) as Array[of T]:
        pass


    # Allow assignment from arrays of the same generic type
    static def op_Implicit(rhs as (T)) as Array[of T]:
        pass

    # Allow assignment from non generic Arrays but only to object generic type
    static def op_Implicit(rhs as Array) as Array[of Object]:
        pass



    def Iterable.iterator() as Iterator:
        pass


    public final length as uint

    # Indexer
    # TODO: Use same optimizations as slicing on arrays
    self[index as int] as T:
        [Transform( Boo.slice($0, $1) )]
        get: pass
        [Transform( Boo.sliceSet($0, $1, $2) )]
        set: pass

    def constructor():
        pass
    def constructor(n as int):
        pass

    # HACK: Emulate multiple params in a Javascript compatible way (up to 3 elements)
    [VarArgs]
    def push(itm as T, *other as (T)) as uint:
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



class Array(Array[of object], Iterable):

    [Transform( Boo.Array.op_Equality($1, $2) )]
    static def op_Equality(lhs as Array, rhs as Array) as bool:
        pass
    [Transform( Boo.Array.op_Member($1, $2) )]
    static def op_Member(lhs as object, rhs as Array) as bool:
        pass
    [Transform( not Boo.Array.op_Member($1, $2) )]
    static def op_NotMember(lhs as object, rhs as Array) as bool:
        pass
    [Transform( Boo.Array.op_Addition($1, $2) )]
    static def op_Addition(lhs as Array, rhs as Array) as Array:
        pass
    [Transform( Boo.Array.op_Multiply($1, $2) )]
    static def op_Multiply(lhs as Array, rhs as int) as Array:
        pass


    # Comply with Iterable interface
    def Iterable.iterator() as Iterator:
        pass


    def constructor():
        pass
    def constructor(n as int):
        pass


    # Ecma 5th edition

    static def isArray(arg as object) as bool:
        pass

