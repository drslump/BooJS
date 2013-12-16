"""
"""

class Foo:
	static FinalSolution = "42"
	_some = 3

	def test():
		assert FinalSolution == "42"
		assert _some == 3

c = Foo()
c.test()
