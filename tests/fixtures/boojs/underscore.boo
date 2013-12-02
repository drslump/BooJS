"""
10
2,4,6
6
"""
def foo(_):
	return _

print foo(10)
print map((1,2,3), {_*2})
a = reduce((1,2,3)) do:
	return _ + _
print a