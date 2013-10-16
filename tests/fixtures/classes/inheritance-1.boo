"""
Foo.foo
Bar.foo
"""

class Foo:
	virtual def foo():
		print 'Foo.foo'

class Bar(Foo):
	override def foo():
		super()
		print 'Bar.foo'

bar = Bar('foo')
bar.foo()
