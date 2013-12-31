#IGNORE: BUG - Ducky invocations still use runtime helpers in some cases
#DUCKY
"""
Foo.bar
42
42
before field
42
before property
42
"""
class Foo:
	[getter(Func)]
	public func as duck
	
	def constructor(func):
		self.func = func
		
	def bar():
		print "Foo.bar"
		func()
		self.func()
		
def bar():
	print "42"
	
f = Foo(bar)
f.bar()
print "before field"
f.func()
print "before property"
f.Func()
		
		
