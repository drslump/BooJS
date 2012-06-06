"""
1
2
Elvin,Jones
1
2
Wilson das Neves
"""
def foo(a, b, *args):
	print a
	print b
	print join(args)
	
foo(1, 2, ("Elvin", "Jones"))
foo(1, 2, *("Wilson", "das", "Neves"))

