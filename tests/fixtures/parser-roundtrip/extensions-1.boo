"""
FOO
1|2|3
"""
[Extension]
static def foo(item as string):
	return item.toUpperCase()
	
[Extension]
static def joinit(item as string, items):
	return join(items, item)

print 'foo'.foo()
print '|'.joinit([1,2,3])