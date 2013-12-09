namespace BooJs.Lang.Globals

from BooJs.Lang.Macros import *


interface Iterable:
""" Enumerable interface (aka IEnumerable)
"""
    def iterator() as Iterator


interface Iterable[of T] (Iterable):
""" Enumerable interface for generic types (aka IEnumerable[of T])
"""
    def iterator() as Iterator[of T]


interface Iterator:
""" Enumerator interface (aka IEnumerator)
"""
    def next() as object


interface Iterator[of T] (Iterator):
""" Enumerator interface for generic types (aka IEnumerator[of T])
"""
    def next() as T


interface GeneratorIterator(Iterable, Iterator):
""" Generator based enumerator
"""
    # Just returns itself (allowing their use in for..in loops)
    def iterator() as GeneratorIterator

    def send(value as object)
    def throw(error as object)
    def close()


interface GeneratorIterator[of T] (GeneratorIterator, Iterable[of T], Iterator[of T]):
""" Generator based enumerator for generic types
"""
    # Just returns itself (allowing their use in for..in loops)
    def iterator() as GeneratorIterator[of T]


internal private interface IArguments:
""" Internal model for the arguments keyword """
    self[index as int] as object:
        get
        set

    length as int:
        get


const NaN = 0
const Infinity = 0
const undefined = null
const arguments as IArguments = null
const StopIteration = null  # Ecma 6


def parseInt(n as string, radix as int) as int:
    pass
def parseInt(n as string) as int:
    pass
def parseFloat(n as string) as double:
    pass

def isFinite(number as double) as bool:
    pass
def isNaN(number as double) as bool:
    pass

def eval(x as string) as object:
    pass

def decodeURI(encodedURI as string) as string:
    pass
def decodeURIComponent(encodedURIComponent as string) as string:
    pass
def encodeURI(uri as string) as string:
    pass
def encodeURIComponent(uriComponent as string) as string:
    pass

# Deprecated in moder Javascript
def escape(str as string) as string:
    pass
def unescape(str as string) as string:
    pass
