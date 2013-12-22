#IGNORE: Implicit conversion not supported yet
"""
f(42)
"""
from BooJs.Tests.Support import ImplicitConversionToDouble

def f(d as double):
	print "f(${d})"

v = ImplicitConversionToDouble(42)
f(v)
d as double = v
assert 42.0 == d

assert 41 < v
assert 43 > v
assert 41 <= v
assert 43 >= v
assert 42.0 == v

