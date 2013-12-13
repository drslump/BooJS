def foo():
	return "foo"
	
def bar():
	return 5
	
def hyphenate(fn as ICallable):
	return "-${fn()}"
	
def upper(fn as callable):
	return fn().toString().toUpperCase()
	
def test(expectedValues as Array, decorator as ICallable):
	assert expectedValues[0] == decorator(foo)
	assert expectedValues[1] == decorator(bar)
	
test(["-foo", "-5"], hyphenate)
test(["FOO", "5"], upper)
