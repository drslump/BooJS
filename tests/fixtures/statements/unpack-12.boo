"""
third
first
second
"""
class Foo:
	public First = null
	public Second = null
	def constructor(value):
		First, Second, third = value
		print third
		
f = Foo(["first", "second", "third"])
print f.First
print f.Second
