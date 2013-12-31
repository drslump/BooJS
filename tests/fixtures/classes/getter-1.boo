"""
10
"""

class Foo:
	[getter(Getter)]
	_field as int

	def constructor(x):
		_field = x

f = Foo(10)

print f.Getter