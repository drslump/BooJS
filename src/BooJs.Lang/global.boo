namespace BooJs.Lang


class Proto(System.Object):
"""
Serves as base for all JS types
"""
    static def op_Addition(lhs as object, rhs as double) as double:
        pass
    static def op_Subtraction(lhs as object, rhs as double) as double:
        pass
    static def op_Subtraction(lhs as object, rhs as object) as object:
        pass
    static def op_Multiply(lhs as object, rhs as double) as double:
        pass
    static def op_Multiply(lhs as object, rhs as object) as double:
        pass
    static def op_Division(lhs as object, rhs as double) as double:
        pass
        
    public prototype as object

    self[key as string] as object:
        get: pass
        set: pass

    def hasOwnProperty(key as string) as bool:
        pass

    def isPrototypeOf(obj as object) as bool:
        pass

    def toString() as string:
        pass


class Duck(Proto, Boo.Lang.IQuackFu):
    # Implements QuackFu interface
    def QuackGet(name as string, params as (object)) as object:
        pass

    def QuackSet(name as string, params as (object), value as object) as object:
        pass

    def QuackInvoke(name as string, args as (object)) as object:
        pass


class Error(Proto):

    public message as string

    def constructor():
        pass
    def constructor(msg as string):
        pass

class EvalError(Error):
        pass

class RangeError(Error):
        pass

class ReferenceError(Error):
        pass

class SyntaxError(Error):
        pass

class TypeError(Error):
        pass

class URIError(Error):
    def constructor(msg as string):
        pass



class Number(Proto):
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

class NumberInt(Number):
    pass

class NumberUInt(Number):
    pass

class NumberDouble(Number):
    pass



class String(Proto):

    # Support formatting: '{0} {1}' % ('foo', 'bar')
    static def op_Modulus(s as string, a as (object)) as string:
        pass
        
    # Support addition between strings (TODO: this method should never be called)
    static def op_Addition(a as string, b as string) as string:
        pass
        
    # Support multiply operator: 'foo' * 2 --> 'foofoo'
    static def op_Multiply(s as string, a as int) as string:
        pass
        
       
    # Static methods

    static def fromCharCode(code as int) as string:
        pass
        
        
    # Instance members
    
    self[index as int] as string:
         get: pass

    public length as uint


    def charAt(idx as int) as string:
        pass
    def charCodeAt(idx as int) as int:
        pass
    def concat(str as string) as string:
        pass
    def indexOf(str as string) as int:
        pass
    def lastIndexOf(str as string) as int:
        pass

    def match(re as RegExp) as bool:
        pass
    def replace(re as RegExp, repl as string) as string:
        pass
    def replace(substr as string, repl as string) as string:
        pass
    def replace(re as RegExp, repl as callable) as string:
        pass
    def replace(substr as string, repl as callable) as string:
        pass

    def split(sep as string) as (string):
        pass

    def substr(start as uint, length as int) as string:
        pass
    def substring(start as uint, stop as int) as string:
        pass

    def toUpperCase() as string:
        pass

    def toLowerCase() as string:
        pass

    def trim() as string:
        pass


class Array(Proto):

    static def op_Member(item as object, arr as Array) as bool:
        return arr.indexOf(item) != -1

    static def op_NotMember(item as object, arr as Array) as bool:
        return arr.indexOf(item) == -1

    static def op_Equality(x as Array, y as Array) as bool:
        pass

    static def op_Addition(lhs as Array, rhs as Array) as Array:
        pass

    static def op_Multiply(lhs as Array, rhs as int) as Array:
        pass

    #self[index as int] as object:
    #    get: pass
    #    set: pass

    public length as uint

    # HACK: Emulate multiple params in a Javascript compatible way (up to 3 elements)
    def push(itm as object) as uint:
        pass
    def push(itm1 as object, itm2 as object) as uint:
        pass
    def push(itm1 as object, itm2 as object, itm3 as object) as uint:
        pass

    def pop() as object:
        pass

    def reverse() as Array:
        return self

    def shift() as object:
        pass

    def sort() as Array:
        return self

    def sort(comp as callable) as Array:
        return self

    def splice(index as int, cnt as int, *elems as (object)) as Array:
        return self
        
    def splice(index as int, cnt as int) as Array:
        return self

    def splice(index as int) as Array:
        return self

    # HACK: Emulate multiple params in a Javascript compatible way (up to 3 elements)
    def unshift(itm1 as object) as uint:
        pass
    def unshift(itm1 as object, itm2 as object) as uint:
        pass
    def unshift(itm1 as object, itm2 as object, itm3 as object) as uint:
        pass

    # HACK: Emulate multiple params in a Javascript compatible way (up to 3 elements)
    def concat(itm1 as Array) as Array:
        pass
    def concat(itm1 as Array, itm2 as Array) as Array:
        pass
    def concat(itm1 as Array, itm2 as Array, itm3 as Array) as Array:
        pass

    def join(sep as string) as string:
        pass

    def slice(start as int, stop as int) as Array:
        pass

    def slice(start as int) as Array:
        pass

    def indexOf(itm as object, start as int) as int:
        pass

    def indexOf(itm as object) as int:
        pass

    def lastIndexOf(itm as object, start as int) as int:
        pass

    def lastIndexOf(itm as object) as int:
        pass


    def filter(callback as callable, context as object) as Array:
        pass
    def filter(callback as callable) as Array:
        pass

    def forEach(callback as callable, context as object) as void:
        pass
    def forEach(callback as callable) as void:
        pass

    def every(callback as callable, context as object) as bool:
        pass
    def every(callback as callable) as bool:
        pass

    def map(callback as callable, context as object) as Array:
        pass
    def map(callback as callable) as Array:
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


class RegExp(Proto):

    public global as bool
    public ignoreCase as bool
    public lastIndex as bool
    public multiline as bool
    public source as string

    def constructor(pattern as string, flags as string):
        pass

    def constructor(pattern as string):
        pass

    def exec(str as string) as Array:
        pass

    def test(str as string) as bool:
        pass


class Function(Proto, ICallable):

    # ICallable interface
    def Call(params as (object)) as object:
        pass



class Math(Proto):

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
      
      
      
class Global(Duck):
""" Special class/type to easily define variables without shadowing them """

    def QuackGet(name as string, params as (object)) as object:
        pass

    def QuackSet(name as string, params as (object), value as object) as object:
        pass

    def QuackInvoke(name as string, args as (object)) as object:
        pass



# Global functions

def parseInt(n as string, base as int) as int:
    pass
def parseInt(n as string) as int:
    pass
    
def parseFloat(n as string) as double:
    pass

