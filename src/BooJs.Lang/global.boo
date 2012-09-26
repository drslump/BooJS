namespace BooJs.Lang

class Proto(System.Object):
"""
Serves as base for all JS types
"""
    static def op_Addition(lhs as Proto, rhs as Number) as Number:
        pass
    static def op_Subtraction(lhs as Proto, rhs as Number) as Number:
        pass
    static def op_Subtraction(lhs as Proto, rhs as Proto) as Proto:
        pass
    static def op_Multiply(lhs as Proto, rhs as Number) as Number:
        pass
    static def op_Division(lhs as Proto, rhs as Number) as Number:
        pass
        
    public prototype as Proto

    self[key as String] as Proto:
        get: pass
        set: pass

    def hasOwnProperty(key as String) as bool:
        pass

    def isPrototypeOf(obj as Proto) as bool:
        pass

    def toString() as String:
        pass


class Duck(Proto, Boo.Lang.IQuackFu):
    # Implements QuackFu interface
    def QuackGet(name as String, params as (Proto)) as Proto:
        pass

    def QuackSet(name as String, params as (Proto), value as Proto) as Proto:
        pass

    def QuackInvoke(name as String, args as (Proto)) as Proto:
        pass


class Error(Proto):

    public message as String

    def constructor():
        pass
    def constructor(msg as String):
        pass

class EvalError(Error):
    def constructor():
        pass
    def constructor(msg as String):
        pass

class RangeError(Error):
    def constructor():
        pass
    def constructor(msg as String):
        pass

class ReferenceError(Error):
    def constructor():
        pass
    def constructor(msg as String):
        pass

class SyntaxError(Error):
    def constructor():
        pass
    def constructor(msg as String):
        pass

class TypeError(Error):
    def constructor():
        pass
    def constructor(msg as String):
        pass

class URIError(Error):
    def constructor():
        pass
    def constructor(msg as String):
        pass



class Number(Proto):

    static def op_Implicit(value as NumberDouble) as Number:
        pass
    static def op_Implicit(value as NumberInt) as Number:
        pass
    static def op_Implicit(value as NumberUInt) as Number:
        pass

    def constructor():
        pass
    def constructor(n as Number):
        pass

    def toExponential() as String:
        pass
    def toFixed() as String:
        pass
    def toPrecission() as String:
        pass

class NumberInt(Number):
    pass

class NumberUInt(Number):
    pass

class NumberDouble(Number):
    pass


class String(Proto):

    self[index as NumberInt] as String:
         get: raise System.NotImplementedException()

    public length as uint

    # Support formatting: '{0} {1}' % ('foo', 'bar')
    static def op_Modulus(s as String, a as Array) as String:
        pass

    def charAt(idx as NumberInt) as String:
        pass
    def charCodeAt(idx as NumberInt) as NumberInt:
        pass
    def concat(str as String) as String:
        pass
    def indexOf(str as String) as NumberInt:
        pass
    def lastIndexOf(str as String) as NumberInt:
        pass

    def match(re as RegExp) as bool:
        pass
    def replace(re as RegExp, repl as String) as String:
        pass
    def replace(substr as String, repl as String) as String:
        pass
    def replace(re as RegExp, repl as Function) as String:
        pass
    def replace(substr as String, repl as Function) as String:
        pass

    def split(sep as String) as (String):
        pass

    def substr(start as NumberUInt, length as NumberInt) as String:
        pass
    def substring(start as NumberUInt, stop as NumberInt) as String:
        pass

    def toUpperCase() as String:
        pass

    def toLowerCase() as String:
        pass

    def trim() as String:
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

    #self[index as NumberInt] as Proto:
    #    get: pass
    #    set: pass

    public length as NumberUInt

    # HACK: Emulate multiple params in a Javascript compatible way (up to 3 elements)
    def push(itm as Proto) as NumberUInt:
        pass
    def push(itm1 as Proto, itm2 as Proto) as NumberUInt:
        pass
    def push(itm1 as Proto, itm2 as Proto, itm3 as Proto) as NumberUInt:
        pass

    def pop() as Proto:
        pass

    def reverse() as Array:
        return self

    def shift() as Proto:
        pass

    def sort() as Array:
        return self

    def sort(comp as Function) as Array:
        return self

    def splice(index as NumberInt, cnt as NumberInt, *elems as (Proto)) as Array:
        return self

    def splice(index as NumberInt) as Array:
        return self

    # HACK: Emulate multiple params in a Javascript compatible way (up to 3 elements)
    def unshift(itm1 as Proto) as NumberUInt:
        pass
    def unshift(itm1 as Proto, itm2 as Proto) as NumberUInt:
        pass
    def unshift(itm1 as Proto, itm2 as Proto, itm3 as Proto) as NumberUInt:
        pass

    # HACK: Emulate multiple params in a Javascript compatible way (up to 3 elements)
    def concat(itm1 as Array) as Array:
        pass
    def concat(itm1 as Array, itm2 as Array) as Array:
        pass
    def concat(itm1 as Array, itm2 as Array, itm3 as Array) as Array:
        pass

    def join(sep as String) as String:
        pass

    def slice(start as NumberInt, stop as NumberInt) as Array:
        pass

    def slice(start as NumberInt) as Array:
        pass

    def indexOf(itm as Proto, start as NumberInt) as NumberInt:
        pass

    def indexOf(itm as Proto) as NumberInt:
        pass

    def lastIndexOf(itm as Proto, start as NumberInt) as NumberInt:
        pass

    def lastIndexOf(itm as Proto) as NumberInt:
        pass


    def filter(callback as Function, context as Proto) as Array:
        pass
    def filter(callback as Function) as Array:
        pass

    def forEach(callback as Function, context as Proto) as void:
        pass
    def forEach(callback as Function) as void:
        pass

    def every(callback as Function, context as Proto) as bool:
        pass
    def every(callback as Function) as bool:
        pass

    def map(callback as Function, context as Proto) as Array:
        pass
    def map(callback as Function) as Array:
        pass

    def some(callback as Function, context as Proto) as bool:
        pass
    def some(callback as Function) as bool:
        pass

    def reduce(callback as Function, initialValue as Proto) as Proto:
        pass
    def reduce(callback as Function) as Proto:
        pass

    def reduceRight(callback as Function, initialValue as Proto) as Proto:
        pass
    def reduceRight(callback as Function) as Proto:
        pass


class RegExp(Proto):

    public global as bool
    public ignoreCase as bool
    public lastIndex as bool
    public multiline as bool
    public source as String

    def constructor(pattern as String, flags as String):
        pass

    def constructor(pattern as String):
        pass

    def exec(str as String) as Array:
        pass

    def test(str as String) as bool:
        pass


class Function(Proto, ICallable):

    # ICallable interface
    def Call(params as (Proto)):
        pass






class global(Boo.Lang.IQuackFu):
""" Special class/type to easily define variables without shadowing them """

    def QuackGet(name as string, params as (object)) as object:
        pass

    def QuackSet(name as string, params as (object), value as object) as object:
        pass

    def QuackInvoke(name as string, args as (object)) as object:
        pass

