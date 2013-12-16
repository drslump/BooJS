"""
null
NULL
NULL
null
null
14
"""
def foo(n as bool):
	return null if n
	return "NULL"
	
def bar(n as bool):
	return "NULL" if n
	return null
	
def baz(n as bool):
	return null if n
	return 14

print foo(true)
print foo(false)

print bar(true)
print bar(false)

print baz(true)
print baz(false)
