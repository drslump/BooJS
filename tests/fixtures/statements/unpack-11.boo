"""
first
second
"""
class Foo:
	public First = null
	public Second = null
	def constructor(value):
		First, Second = value
		
f = Foo(["first", "second"])
print f.First
print f.Second
