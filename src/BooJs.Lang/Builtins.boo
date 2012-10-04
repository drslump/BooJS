namespace BooJs.Lang

# NOTE: We need to use the Javascript compatible types instead of the primitive ones (int, string, object, ...)

class Builtins:

    static Version as string

    static def range(stop as int) as (int):
        pass
    static def range(start as int, stop as int) as (int):
        pass
    static def range(start as int, stop as int, step as int) as (int):
        pass

    static def print(*list as (object)) as void:
        pass

    static def cat(*list as (object)) as Array:
    """ Concatenates the given enumerable arguments """
        pass

    static def join(items as (object), separator as string) as string:
        pass
    static def join(items as (object)) as string:
        pass

    static def map(items as (object), callback as callable) as (object):
        pass

    static def reduce[of T](items as (T), callback as callable) as T:
        pass
    static def reduce[of T](items as (T), callback as callable, initial as T) as T:
        pass

    static def zip(*arrays as (object)) as (object):
        pass

    static def reversed(items as (object)) as (object):
        pass
    static def reversed(items as string) as (object):
        pass

    # TODO: Do we need this?
    static def prompt(msg as String):
        pass


    # TODO: The annotation does not work :(
    #[TypeInferenceRule(TypeInferenceRules.ArrayOfTypeReferencedByFirstArgument)]
    #def array(type as System.Type, enumerable as System.Collections.IEnumerable):
    #    pass

    #[TypeInferenceRule(TypeInferenceRules.ArrayOfTypeReferencedByFirstArgument)]
    #def array(type as System.Type, num as int):
    #    pass

    static def array(type as System.Type, enumerable as (object)) as Array:
        pass
    static def array(type as System.Type, num as int) as Array:
        pass
    static def array(enumerable as (object)) as Array:
        pass


    # Allows to iterate accesing indices/keys
    static def enumerate(enumerable as (object)) as Array:
        pass

