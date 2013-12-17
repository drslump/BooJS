"""
3
"""
enum Foo:
	Spam = 1
	Eggs = 2
	All = 3

a = 1 | 2 & 3 | 2
a = Foo.Spam | Foo.Eggs & Foo.All

print a
