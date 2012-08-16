#IGNORE enums not fully supported yet
"""
Bar
3
"""
enum Foo:
	Bar = 3
	
print(Foo.Bar)
print(cast(int, Foo.Bar))
