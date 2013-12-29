"""
foo
"""
namespace ITL.PM

class Project:

	_name as string

	def constructor(name as string):
		_name = name

	def getName():
		return _name

p = Project('foo')
print p.getName()

