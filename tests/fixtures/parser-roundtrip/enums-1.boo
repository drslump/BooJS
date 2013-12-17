"""
0 1 42
42
0 1
"""
enum AnEnum:
	Foo
	Bar = 1
	Baz = 42
	
enum AnotherEnum:
	Foo = 42
	
enum YetAnother:
	Foo
	Bar

enum Empty:
	pass

print AnEnum.Foo, AnEnum.Bar, AnEnum.Baz
print AnotherEnum.Foo
print YetAnother.Foo, YetAnother.Bar