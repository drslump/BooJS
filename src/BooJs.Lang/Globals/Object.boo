namespace BooJs.Lang.Globals


class Object(System.Object):
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

    public prototype as Object

    self[key as string] as object:
        get: pass
        set: pass

    def hasOwnProperty(key as string) as bool:
        pass

    def isPrototypeOf(obj as object) as bool:
        pass

    def toString() as string:
        pass
    def toLocaleString() as string:
        pass

    def valueOf() as Object:
        pass

    def propertyIsEnumerable(name as string) as bool:
        pass


    # ECMAScript 5th Edition

    # These are no real classes in Javascript
    class PropertyDescriptor:
        configurable as bool?
        enumerable as bool?
        value as object
        writable as bool?
        _get as callable
        _set as callable

    class PropertyDescriptorMap:
        self[key as string] as PropertyDescriptor:
            get: pass
            set: pass


    static def getPrototypeOf(obj as object) as object:
        pass
    static def getOwnPropertyDescriptor(obj as object, prop as string) as PropertyDescriptor:
        pass
    static def getOwnPropertyNames(obj as object) as string*:
        pass
    static def create(obj as object) as object:
        pass
    static def create(obj as object, properties as PropertyDescriptorMap) as object:
        pass
    static def defineProperty(obj as object, p as string, attributes as PropertyDescriptor) as object:
        pass
    static def defineProperties(obj as object, properties as PropertyDescriptorMap) as object:
        pass
    static def seal(obj as object) as object:
        pass
    static def freeze(obj as object) as object:
        pass
    static def preventExtensions(obj as object) as object:
        pass
    static def isSealed(obj as object) as bool:
        pass
    static def isFrozen(obj as object) as bool:
        pass
    static def isExtensible(obj as object) as bool:
        pass
    static def keys(obj as object) as string*:
        pass

