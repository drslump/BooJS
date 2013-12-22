#IGNORE: Type system not fully supported yet
"""
Foo.Bar.Person[][]
"""
namespace Foo.Bar

class Person:
	pass

items = ((Person(), Person()), (Person(),))
print(items.GetType())
