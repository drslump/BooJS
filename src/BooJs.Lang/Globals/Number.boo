namespace BooJs.Lang.Globals

class Number(Object):

    static public NaN as double
    static public MAX_VALUE as double
    static public MIN_VALUE as double
    static public NEGATIVE_INFINITY as double
    static public POSITIVE_INFINITY as double


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

class NumberUInt(Number):
    pass

class NumberDouble(Number):
    pass
