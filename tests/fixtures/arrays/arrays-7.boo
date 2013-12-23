#UNSUPPORTED: Reflection not supported yet
"""
Person[][]
"""
class Person:
	pass

items = ((Person(), Person()), (Person(),))
print(items.GetType())
