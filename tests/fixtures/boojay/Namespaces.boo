"""
"""
namespace foo.bar

class Foo:
	pass
	
assert Foo == js(`Boo.require('foo.bar').Foo`)