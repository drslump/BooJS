#IGNORE: Yield not fully supported yet
"""
FOO
BAR
"""
namespace generators

def foobar():
	yield "foo"
	yield "bar"
	
for s in foobar():
	print s.toUpperCase()