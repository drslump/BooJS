#IGNORE: BUG: overloading resolution for numbers
"""
bar(int, int, int)
bar(single, single, single)
bar(single, single, single)
bar(single, single, single)
"""
class Foo:
	def bar(a1 as int, a2 as int, a3 as int):
		print "bar(int, int, int)"
		
	def bar(a1 as double, a2 as double, a3 as double):
		print "bar(single, single, single)"
	
i as int
s as double

foo = Foo()
foo.bar(i, i, i)
foo.bar(i, i, s)
foo.bar(i, s, s)
foo.bar(s, s, s)
