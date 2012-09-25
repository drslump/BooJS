namespace BooJs.Lang


# NOTE: We need to use the Javascript compatible types instead of the primitive ones (int, string, object, ...)

def range(stop as NumberInt) as (NumberInt):
    pass
def range(start as NumberInt, stop as NumberInt) as (NumberInt):
    pass
def range(start as NumberInt, stop as NumberInt, step as NumberInt) as (NumberInt):
    pass


def print(*list as (Proto)) as void:
    pass

def cat(*list as (Proto)) as Array:
""" Concatenates the given enumerable arguments """
    pass

def join(items as (Proto), separator as String) as String:
    pass
def join(items as (Proto)) as String:
    pass

def map(items as (Proto), callback as Function) as (Proto):
    pass

def reduce(items as (Proto), callback as Function) as Proto:
    pass

def zip(*arrays as (Proto)) as (Proto):
    pass

def reversed(items as (Proto)) as (Proto):
    pass
def reversed(items as String) as (Proto):
    pass

def prompt(msg as String):
    pass


# TODO: The annotation does not work :(
#[TypeInferenceRule(TypeInferenceRules.ArrayOfTypeReferencedByFirstArgument)]
#def array(type as System.Type, enumerable as System.Collections.IEnumerable):
#    pass

#[TypeInferenceRule(TypeInferenceRules.ArrayOfTypeReferencedByFirstArgument)]
#def array(type as System.Type, num as int):
#    pass

def array(type as System.Type, enumerable as (Proto)) as Array:
    pass
def array(type as System.Type, num as NumberInt) as Array:
    pass
def array(enumerable as (Proto)) as Array:
    pass
