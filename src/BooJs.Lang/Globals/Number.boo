namespace BooJs.Lang.Globals

class Number(Object):

    static final NaN as double
    static final MAX_VALUE as double
    static final MIN_VALUE as double
    static final NEGATIVE_INFINITY as double
    static final POSITIVE_INFINITY as double


    def constructor():
        pass
    def constructor(n as double):
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
    pass

class NumberUInt(NumberInt):
    pass

class NumberDouble(Number):
    pass
