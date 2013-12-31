"""
Donald
"""
namespace MultiFileTest

class Character:

	[getter(Name)]
	_name as string
	
	def constructor(name as string):
		_name = name

c = Character("Donald")
print c.Name	
	
