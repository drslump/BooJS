"""
1
2
Wilson das Neves
"""
callable Func(a, b, *args)

def foo(a, b, args as (object)):
	print a
	print b
	print join(args)
	
f as Func = foo
f(1, 2, *("Wilson", "das", "Neves"))

