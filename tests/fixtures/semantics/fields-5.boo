class ClassWithField:
	def constructor():
		pass

	_name = ""

	def test():
		assert _name == ''


c = ClassWithField()
c.test()
