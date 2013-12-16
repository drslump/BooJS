#IGNORE: Ast types not supported
"""
def foo():
	return [|
		return 3
	|]


def bar():
	return [|
		print 'Hello, world'
	|]
"""
def foo():
	return [|
		return 3
	|]
def bar():
	return [| print 'Hello, world' |]
