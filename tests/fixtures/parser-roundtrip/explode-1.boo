"""
10 20 30
"""
def foo(*args):
	print bar(*args)
	
def bar(*args):
	return join(args)

foo(10, 20, 30)