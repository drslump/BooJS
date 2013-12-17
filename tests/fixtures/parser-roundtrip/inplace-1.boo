"""
15 1
"""
enum Foo:
	Bar = 1
	Baz = 2
	Spam = 4
	Eggs = 8

enum Zeng:
	Bar = 1
	Baz = 3

a = Foo.Bar
a |= Foo.Baz
a |= Foo.Spam | Foo.Eggs
b = Zeng.Bar
b &= Zeng.Baz

print a, b