namespace BooJs.Lang.Runtime

import BooJs.Lang.Extensions


class Services:

    [JsTransform('Boo.op_Equality($0, $1)')]
    static def Equality(lhs as object, rhs as object) as bool:
        pass

    [JsAlias('Boo.enumerable')]
    static def Enumerable(list as object) as object*:
        pass

    #[JsAlias('Boo.each')]
    [JsTransform( Boo.each($0, $1) )]
    static def Each(list as object*, callback as callable) as object:
        pass


    # HACK: We name the methods differently since we don't have a clean way
    #       to resolve an overloaded method based on their params from the
    #       compiler step, so this simplifies their use.
    [JsTransform( Boo.slice($0, $1) )]
    static def slice1[of T](list as T*, begin as int) as T:
        pass
    [JsTransform( Boo.slice($0, $1, $2) )]
    static def slice2[of T](list as T*, begin as int, end as int) as T*:
        pass
    [JsTransform( Boo.slice($0, $1, $2, $3) )]
    static def slice3[of T](list as T*, begin as int, end as int, step as int) as T*:
        pass


    # TODO: When any type doesn't have a explicit operator overload they seem to use the ones from other types :-s



    # TODO: We need to think how strings are handled when used like numbers
    [JsTransform( $0 == $1 )]
    [Extension] static def op_Equality(lhs as double, rhs as string) as bool:
        pass
    [JsTransform( $0 + $1 )]
    [Extension] static def op_Addition(lhs as double, rhs as string) as string:
        pass
    [JsTransform( $0 + $1 )]
    [Extension] static def op_Addition(lhs as string, rhs as double) as string:
        pass

