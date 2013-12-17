"""
42
42 42
"""
class Foo:
	public value as int
	def operation():
		return value

with Foo():
	.value = 42
	a = .value
	b = .operation()
	print(.value)
	print a, b

