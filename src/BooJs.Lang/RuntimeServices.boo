namespace BooJs.Lang

import BooJs.Lang.Extensions


class RuntimeServices:

    [Transform( Boo.op_Equality($1, $2) )]
    static def Equality(lhs as object, rhs as object) as bool:
        pass

    [Transform( Boo.enumerable($1) )]
    static def Enumerable(list as object) as object*:
        pass

    [Transform( Boo.each($1, $2) )]
    static def Each(list as object*, callback as callable) as object:
        pass

    [Transform( Boo.len($1) )]
    static def Len(list as object) as int:
        pass


    # Duck dynamic dispatching

    [Transform( $1[$2]($3) )]
    static def Invoke(target as object, method as string, args as object*) as object:
        pass
    static def InvokeCallable(target as object, args as object*) as object:
        pass
    static def InvokeUnaryOperator(operator as string, operand as object) as object:
        pass
    static def InvokeBinaryOperator(operator as string, lhs as object, rhs as object) as object:
        pass
    [Transform( $1[$2] = $3 )]
    static def SetProperty(target as object, name as string, value as object) as object:
        pass
    [Transform( $1[$2] )]
    static def GetProperty(target as object, name as string) as object:
        pass
    [Transform( Boo.slice_set($1, $2, $3) )]
    static def SetSlice(target as object, name as string, args as object*) as object:
        pass
    [Transform( Boo.slice($1, $2, $3) )]
    static def GetSlice(target as object, name as string, args as object*) as object:
        pass


    # HACK: Needed to support varargs with the original ImplementICallableOnCallableDefinitions step
    static def GetRange1(source as System.Array, begin as int) as System.Array:
        pass


    # HACK: We name the methods differently since we don't have a clean way
    #       to resolve an overloaded method based on their params from the
    #       compiler step, so this simplifies their use.
    [Transform( Boo.slice($1, $2) )]
    static def slice1[of T](list as T*, begin as int) as T:
        pass
    [Transform( Boo.slice($1, $2, $3) )]
    static def slice2[of T](list as T*, begin as int, end as int) as T*:
        pass
    [Transform( Boo.slice($1, $2, $3, $4) )]
    static def slice3[of T](list as T*, begin as int, end as int, step as int) as T*:
        pass


    # TODO: When a type doesn't have a explicit operator overload they seem to use the ones from other types :-s


    # Duck values are directly compared by Javascript
    [Transform( $1 == $2 )]
    [Extension] static def op_Equality(lhs as duck, rhs as object) as bool:
        pass
