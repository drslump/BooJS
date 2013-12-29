"""
Foo = 0
Bar = 1
"""
partial enum E:
	Foo
	
partial enum E:
	Bar

print "Foo = $(E.Foo)"
print "Bar = $(E.Bar)"
