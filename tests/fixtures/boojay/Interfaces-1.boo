#IGNORE: interfaces not supported yet
"""
yeah
"""
interface Foo:
	def bar()

class FooImpl(Foo):
	def bar():
		print "yeah"
		
def useFoo(f as Foo):
	f.bar()
	
useFoo(FooImpl())    
