"""
"""
class Foo:
	_first = 14
	_second = _first*2
	
	def constructor():
		pass
		
	def constructor(bar):
		pass

	def test():
		assert _first == 14
		assert _second == 28


c = Foo()
c.test()
