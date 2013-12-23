#UNSUPPORTED: passing by reference is not supported
"""
42
"""
def foo(ref i as int):
	i = 42
	
f = foo
i = 0
f(i)
print i
