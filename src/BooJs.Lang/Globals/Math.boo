namespace BooJs.Lang.Globals


static class Math(Object):

    # Euler's constant and the base of natural logarithms
    final E =  2.718
    # Natural logarithm of 2
    final LN2 = 0.693
    # Natural logarithm of 10
    final LN10 = 2.303
    # Base 2 logarithm of E
    final LOG2E = 1.443
    # Base 10 logarithm of E
    final LOG10E = 0.434
    # Ratio of the circumference of a circle to its diameter
    final PI = 3.14159
    # Square root of 1/2; equivalently, 1 over the square root of 2
    final SQRT1_2 = 0.707
    # Square root of 2
    final SQRT2 = 1.414

    def abs(n as double) as int:
      pass

    def acos(n as double) as double:
      pass
      
    def asin(n as double) as double:
      pass
    
    def atan(n as double) as double:
      pass
    
    def atan2(y as double, x as double) as double:
      pass

    def ceil(n as double) as int:
      pass

    def cos(n as double) as double:
      pass

    def exp(n as double) as double:
      pass
      
    def floor(n as double) as int:
      pass
      
    def log(n as double) as double:
      pass
      
    # HACK: Emulate variable number of arguments
    def max(n1 as double, n2 as double) as double:
      pass
    def max(n1 as double, n2 as double, n3 as double) as double:
      pass
    def max(n1 as double, n2 as double, n3 as double, n4 as double) as double:
      pass

    # HACK: Emulate variable number of arguments
    def min(n1 as double, n2 as double) as double:
      pass
    def min(n1 as double, n2 as double, n3 as double) as double:
      pass
    def min(n1 as double, n2 as double, n3 as double, n4 as double) as double:
      pass

    def pow(base as double, exp as double) as double:
      pass
      
    def random() as double:
      pass

    def round(n as double) as int:
      pass

    def sin(n as double) as double:
      pass

    def tan(n as double) as double:
      pass
