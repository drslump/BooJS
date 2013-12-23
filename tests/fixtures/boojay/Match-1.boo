"""
Eric Idle
42
"""
class Person:
	public name as string
	
def personNameOrString(o):
	match o:
		case Person(name):
			return name
		otherwise:
			return o.toString()

p = Person(name: "Eric Idle")
print personNameOrString(p)
print 42
