#UNSUPPORTED: DynamicInvoke not supported
import System


def foo():
	return "foo"
	
if Environment.Version < Version(2, 0):
	d1 as Delegate = foo
	assert "foo" == d1.DynamicInvoke(null)

	d2 as MulticastDelegate = foo
	assert "foo" == d2.DynamicInvoke(null)

d3 as ICallable = foo
assert "foo" == d3()
