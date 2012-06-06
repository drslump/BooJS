namespace BooJs.Lang

def range(stop as int):
    return range(0, stop, 1)

def range(start as int, stop as int):
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

def reversed(items as (object)) as (object):
    pass

def prompt(msg as string):
    pass
