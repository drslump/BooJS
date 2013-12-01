namespace BooJs.Lang.Globals

from BooJs.Lang.Extensions import TransformAttribute

class Number(Object):

    [Transform( Math.pow($1, $2) )]
    static def op_Exponentiation(lhs as double, rhs as double) as double:
        pass

    [Transform( $1 + $2 )]
    static def op_Addition(lhs as double, rhs as string) as string:
        pass

    static final NaN as double
    static final MAX_VALUE as double
    static final MIN_VALUE as double
    static final NEGATIVE_INFINITY as double
    static final POSITIVE_INFINITY as double

    [Transform( Boo['cast']($1, 'double') )]
    static def parse(v) as double:
        pass

    [Transform( Number() )]
    def constructor():
        pass

    [Transform( Number($1) )]
    def constructor(n as object):
        pass

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
    [Transform( parseInt($1 / $2) )]
    static def op_Division(lhs as int, rhs as int) as int:
        pass
    # Exponentiation
    [Transform( Math.pow($1, $2) )]
    static def op_Exponentiation(lhs as int, rhs as int) as int:
        pass

    [Transform( Boo.String.op_Multiply($2, $1) )]
    static def op_Multiply(lhs as int, rhs as string) as string:
        pass

    [Transform( Boo['cast']($1, 'int') )]
    static def parse(v) as int:
        pass

    [Transform( Number() )]
    def constructor():
        pass

    [Transform( Number($1) )]
    def constructor(n as object):
        pass

class NumberUInt(NumberInt):
    [Transform( Boo['cast']($1, 'uint') )]
    static def parse(v) as uint:
        pass

    [Transform( Number() )]
    def constructor():
        pass

    [Transform( Number($1) )]
    def constructor(n as object):
        pass


