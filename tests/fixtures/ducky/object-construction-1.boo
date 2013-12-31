#IGNORE: BUG - some ducky calls still use runtime helper
#DUCKY
"""
John Cleese
Fifi
"""
class Person:
	property Name = ""
	
class Dog:
	property Name = ""
	
def New(type as Object, name as string):
	return type(Name: name)
	
p = New(Person, "John Cleese")
assert p isa Person
print p.Name

d = New(Dog, "Fifi")
assert d isa Dog
print d.Name


