"""
Foo:foo
Foo:bar
Foo:baz
"""

class Foo:
	prefix as string

	def constructor():
		self.prefix = 'Foo'

	def foo():
		yield self.prefix + ':foo'
		yield self.prefix + ':bar'
		yield self.prefix + ':baz'


f = Foo()
for i in f.foo():
	print i