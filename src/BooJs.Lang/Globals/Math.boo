namespace BooJs.Lang.Globals


class Math(Object):

    # Euler's constant and the base of natural logarithms
    static final E =  2.718
    # Natural logarithm of 2
    static final LN2 = 0.693
    # Natural logarithm of 10
    static final LN10 = 2.303
    # Base 2 logarithm of E
    static final LOG2E = 1.443
    # Base 10 logarithm of E
    static final LOG10E = 0.434
    # Ratio of the circumference of a circle to its diameter
    static final PI = 3.14159
    # Square root of 1/2; equivalently, 1 over the square root of 2
    static final SQRT1_2 = 0.707
    # Square root of 2
    static final SQRT2 = 1.414

    static def abs(n as double) as int:
      pass

    static def acos(n as double) as double:
      pass
      
    static def asin(n as double) as double:
      pass
    
    static def atan(n as double) as double:
      pass
    
    static def atan2(y as double, x as double) as double:
      pass

    static def ceil(n as double) as int:
      pass

    static def cos(n as double) as double:
      pass

    static def exp(n as double) as double:
      pass
      
    static def floor(n as double) as int:
      pass
      
    static def log(n as double) as double:
      pass
      
    # HACK: Emulate variable number of arguments
    static def max(n1 as double, n2 as double) as double:
      pass
    static def max(n1 as double, n2 as double, n3 as double) as double:
      pass
    static def max(n1 as double, n2 as double, n3 as double, n4 as double) as double:
      pass

    # HACK: Emulate variable number of arguments
    static def min(n1 as double, n2 as double) as double:
      pass
    static def min(n1 as double, n2 as double, n3 as double) as double:
      pass
    static def min(n1 as double, n2 as double, n3 as double, n4 as double) as double:
      pass

    static def pow(base as double, exp as double) as double:
      pass
      
    static def random() as double:
      pass

    static def round(n as double) as int:
      pass

    static def sin(n as double) as double:
      pass

    static def tan(n as double) as double:
      pass


