#IGNORE: Type system reflection not fully supported
"""
Person[][]
"""
class Person:
	pass

items = ((Person(), Person()), (Person(),))
print(items.GetType())
