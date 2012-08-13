"""
foo
bar
"""
def foo():
	print "foo"
	return "foo"
	
def bar():
	print "bar"
	return "bar"
	
c = @(foo(), a=1, bar())
assert c == "bar"
