namespace BooJs.Lang

def range(stop as int) as (int):
    return range(0, stop, 1)

def range(start as int, stop as int) as (int):
    return range(start, stop, 1)

def range(start as int, stop as int, step as int) as (int):
    pass


def print(*list as (object)) as void:
    pass


def cat(*list as (object)) as (object):
""" Concatenates the given enumerable arguments """
    pass

def join(items as (object)):
    return join(items, ' ')

def join(items as (object), separator as string) as string:
    pass

def map(items as (object), callback as callable) as (object):
    pass

#def zip(*arrays as (object)) as (object):
#    pass

def reversed(items as (object)) as (object):
    pass

def prompt(msg as string):
    pass


# TODO: The annotation does not work :(
#[TypeInferenceRule(TypeInferenceRules.ArrayOfTypeReferencedByFirstArgument)]
#def array(type as System.Type, enumerable as System.Collections.IEnumerable):
#    pass

#[TypeInferenceRule(TypeInferenceRules.ArrayOfTypeReferencedByFirstArgument)]
#def array(type as System.Type, num as int):
#    pass

def array(type as System.Type, enumerable as (object)) as Array:
    pass

def array(type as System.Type, num as int) as Array:
    pass

def array(enumerable as (object)) as Array:
    pass
