#IGNORE: Casting to Callable definitions is not supported yet

import System


callable Function(item) as object

def identity(item):
	return item
	
d as ICallable = cast(Function, identity)
f as Function = d
assert "foo" == f("foo")
