namespace BooJs.Lang.Runtime

import BooJs.Lang.Globals
import BooJs.Lang.Extensions


class Services:
    # HACK: We name the methods differently since we don't have a clean way
    #       to resolve an overloaded method based on their params from the
    #       compiler step, so this simplifies their use.
    [JsRewrite('Boo.slice($1, $2)')]
    static def slice1[of T](list as T*, begin as int) as T:
        pass
    [JsRewrite('Boo.slice($1, $2, $3)')]
    static def slice2[of T](list as T*, begin as int, end as int) as T*:
        pass
    [JsRewrite('Boo.slice($1, $2, $3, $4)')]
    static def slice3[of T](list as T*, begin as int, end as int, step as int) as T*:
        pass


    # TODO: When any type doesn't have a explicit operator overload they seem to use the ones from other types :-s

    # Multiply operator: 'foo' * 2 --> 'foofoo'
    [JsAlias('Boo.String.op_Multiply')]
    [Extension] static def op_Multiply(lhs as string, rhs as int) as string:
        pass
    [JsRewrite('Boo.String.op_Multiply($2, $1)')]
    [Extension] static def op_Multiply(lhs as int, rhs as string) as string:
        pass
    # Formatting: '{0} {1}' % ('foo', 'bar')
    [JsAlias('Boo.String.op_Modulus')]
    [Extension] static def op_Modulus(lhs as string, rhs as object*) as string:
        pass

    # Handle integer divisions
    [JsRewrite('parseInt($1 / $2)')]
    [Extension] static def op_Division(lhs as int, rhs as int) as int:
        pass
    # Exponentiation
    [JsRewrite('Math.pow($1, $2)')]
    [Extension] static def op_Exponentiation(lhs as int, rhs as int) as int:
        pass
    [JsRewrite('Math.pow($1, $2)')]
    [Extension] static def op_Exponentiation(lhs as double, rhs as double) as double:
        pass

    # TODO: We need to think how strings are handled when used like numbers
    [JsRewrite('$1 == $2')]
    [Extension] static def op_Equality(lhs as double, rhs as string) as bool:
        pass
    [JsRewrite('$1 == $2')]
    [Extension] static def op_Equality(lhs as string, rhs as string) as bool:
        pass
    [JsRewrite('$1 + $2')]
    [Extension] static def op_Addition(lhs as double, rhs as string) as string:
        pass
    [JsRewrite('$1 + $2')]
    [Extension] static def op_Addition(lhs as string, rhs as double) as string:
        pass


    # Array
    [JsAlias('Boo.Array.op_Equality')]
    [Extension] static def op_Equality(lhs as Array, rhs as Array) as bool:
        pass
    [JsAlias('Boo.Array.op_Equality')]
    [Extension] static def op_Equality(lhs as object*, rhs as object*) as bool:
        pass
    [JsAlias('Boo.Array.op_Member')]
    [Extension] static def op_Member(lhs as Array, rhs as object) as bool:
        pass
    [JsRewrite('!Boo.Array.op_Member($1, $2)')]
    [Extension] static def op_NotMember(lhs as Array, rhs as object) as bool:
        pass
    [JsAlias('Boo.Array.op_Addition')]
    [Extension] static def op_Addition(lhs as Array, rhs as Array) as Array:
        pass
    [JsAlias('Boo.Array.op_Multiply')]
    [Extension] static def op_Multiply(lhs as Array, rhs as int) as Array:
        pass

