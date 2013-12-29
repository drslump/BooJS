"""
boo
"""
class Language:

	_name as string
	
	def constructor(name as string):
		_name = name
		
	def toString() as string:
		return _name
		
print Language("boo")

