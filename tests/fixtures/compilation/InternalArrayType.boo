#IGNORE: Properties not fully supported yet
"""
Foo[]
"""
class Foo:
	Foos as (Foo):
		get: return array(Foo, 0)
		
print Foo().Foos
		


