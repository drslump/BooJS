namespace BooJs.Lang.Globals

import BooJs.Lang.Extensions

class Number(Object):

    static final NaN as double
    static final MAX_VALUE as double
    static final MIN_VALUE as double
    static final NEGATIVE_INFINITY as double
    static final POSITIVE_INFINITY as double


    def toExponential(digits as int) as string:
        pass
    def toExponential() as string:
        pass
    def toFixed(decimals as int) as string:
        pass
    def toFixed() as string:
        pass
    def toPrecission(decimals as int) as string:
        pass
    def toPrecission() as string:
        pass

    def toString(radix as int) as string:
        pass


class NumberInt(Number):
    # Handle integer divisions
    [JsTransform( parseInt($0 / $1) )]
    static def op_Division(lhs as int, rhs as int) as int:
        pass
    # Exponentiation
    [JsTransform( Math.pow($0, $1) )]
    static def op_Exponentiation(lhs as int, rhs as int) as int:
        pass

    [JsTransform( Boo.String.op_Multiply($1, $0) )]
    static def op_Multiply(lhs as int, rhs as string) as string:
        pass

    def constructor():
        pass

    def constructor(n as object):
        pass

class NumberUInt(NumberInt):
    def constructor():
        pass

    def constructor(n as object):
        pass


class NumberDouble(Number):
    # Exponentiation
    [JsTransform( Math.pow($0, $1) )]
    static def op_Exponentiation(lhs as double, rhs as double) as double:
        pass

    def constructor():
        pass
    # TODO: We might want to be more strict on this calling a runtime method
    def constructor(n as object):
        pass