"""
0
Foo.sfoo
Foo.foo
bar
ext
op_Division
"""
enum Enum:
	John
	Ginna

class Foo:
	static def sfoo():
		print 'Foo.sfoo'

	def foo():
		print 'Foo.foo'

def bar():
	print 'bar'

[extension]
def ext(s as string):
	print 'ext'

[extension] def op_Division(lhs as string, rhs as string) as string:
	return 'op_Division'


print Enum.John

Foo.sfoo()
f = Foo()
f.foo()

bar()

'foo'.ext()

print 'foo' / 'bar'