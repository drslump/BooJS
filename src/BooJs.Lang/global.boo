namespace BooJs.Lang

class ProtoObject(System.Object):
"""
Serves as base for all JS types
"""
    public prototype as Object

    def hasOwnProperty(key as string) as bool:
        pass

    def isPrototypeOf(obj as object) as bool:
        pass

    def toString() as string:
        pass


class Object(ProtoObject, Boo.Lang.IQuackFu):
"""
Models the Javascript Object type
"""
    self[key as string] as object:
        get: pass
        set: pass

    # Implements QuackFu interface
    def QuackGet(name as string, params as (object)) as object:
        pass

    def QuackSet(name as string, params as (object), value as object) as object:
        pass

    def QuackInvoke(name as string, args as (object)) as object:
        pass


class Error(ProtoObject):

    public message as string

    def constructor():
        pass
    def constructor(msg as string):
        pass

class EvalError(Error):
    def constructor():
        pass
    def constructor(msg as string):
        pass

class RangeError(Error):
    def constructor():
        pass
    def constructor(msg as string):
        pass

class ReferenceError(Error):
    def constructor():
        pass
    def constructor(msg as string):
        pass

class SyntaxError(Error):
    def constructor():
        pass
    def constructor(msg as string):
        pass

class TypeError(Error):
    def constructor():
        pass
    def constructor(msg as string):
        pass

class URIError(Error):
    def constructor():
        pass
    def constructor(msg as string):
        pass



class Number(ProtoObject):
    static def op_Implicit(value as double) as Number:
        pass
    static def op_Implicit(value as int) as Number:
        pass
    static def op_Implicit(value as uint) as Number:
        pass

    def constructor(n as int):
        pass

    def constructor(n as uint):
        pass

    def constructor(n as double):
        pass

    def toExponential() as string:
        pass
    def toFixed() as string:
        pass
    def toPrecission() as string:
        pass


class String(ProtoObject):

    self[index as int] as String:
         get: raise System.NotImplementedException()

    public length as uint

    # Support formatting: '{0} {1}' % ('foo', 'bar')
    static def op_Modulus(s as String, a as Array) as String:
        pass

    def charAt(idx as int) as String:
        pass
    def charCodeAt(idx as int) as int:
        pass
    def concat(str as string) as String:
        pass
    def indexOf(str as string) as int:
        pass
    def lastIndexOf(str as string) as int:
        pass

    def match(re as System.Text.RegularExpressions.Regex) as bool:
        pass
    def replace(re as System.Text.RegularExpressions.Regex, repl as string) as String:
        pass
    def replace(substr as String, repl as String) as String:
        pass
    def replace(re as System.Text.RegularExpressions.Regex, repl as callable) as String:
        pass
    def replace(substr as String, repl as callable) as String:
        pass

    def split(sep as String) as (String):
        pass

    def substr(start as uint, length as int) as String:
        pass
    def substring(start as uint, stop as int) as String:
        pass

    def toUpperCase() as String:
        pass

    def toLowerCase() as String:
        pass

    def trim() as String:
        pass


class Array(ProtoObject):

    self[index as int] as object:
        get: pass
        set: pass

    public length as uint


    static def op_Member(item as object, arr as Array) as bool:
        return arr.indexOf(item) != -1

    static def op_NotMember(item as object, arr as Array) as bool:
        return arr.indexOf(item) == -1

    static def op_Equality(x as Array, y as Array) as bool:
        pass


    # HACK: Emulate multiple params in a Javascript compatible way (up to 3 elements)
    def push(itm as object) as uint:
        pass
    def push(itm1 as object, itm2 as object) as uint:
        pass
    def push(itm1 as object, itm2 as object, itm3 as object) as uint:
        pass

    def pop() as object:
        pass

    def reverse():
        return self

    def shift() as object:
        pass

    def sort():
        return self

    def sort(comp as callable):
        return self

    def splice(index as int, cnt as int, *elems as (object)):
        return self

    def splice(index as int):
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


class RegExp(ProtoObject):

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


class Function(ProtoObject, ICallable):

    # ICallable interface
    def Call(params as (object)):
        pass









class global(Boo.Lang.IQuackFu):
""" Special class/type to easily define variables without shadowing them """

    def QuackGet(name as string, params as (object)) as object:
        pass

    def QuackSet(name as string, params as (object), value as object) as object:
        pass

    def QuackInvoke(name as string, args as (object)) as object:
        pass

