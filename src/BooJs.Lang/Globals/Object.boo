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
