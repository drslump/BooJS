"""
foo(string)
"""
def foo(ch as string):
	print "foo(string)"
	
def foo(o as object):
	print "foo(object)"
	
for ch in "f":
	foo(ch)

