#IGNORE: Classes not supported
"""
"""
static class Bar:
	def foo():
		yield 42
		
assert not Bar.foo().GetType().IsSerializable
