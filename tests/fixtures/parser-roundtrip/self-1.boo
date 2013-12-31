#IGNORE: BUG - Type references not properly mapped to namespaces
"""
juan
"""
class Customer:

	_name as string
	
	def constructor(name):
		self._name = name
		
	This:
		get:
			return self
			
	Name as string:
		get:
			return self._name


c = Customer("juan")
assert c.This isa Customer
print c