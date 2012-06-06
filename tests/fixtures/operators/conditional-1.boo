"""
true
inside foo
FOO
false
inside bar
BAR
"""
def myeval(condition):
	return (foo() if condition else bar())
	
def foo():
	print "inside foo"
	return "foo"
	
def bar():
	print "inside bar"
	return "bar"
	
print "true"
print myeval(true).toUpperCase()
print "false"
print myeval(false).toUpperCase()

