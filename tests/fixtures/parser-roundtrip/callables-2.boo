"""
0
1
0,1
"""
def each(items, action as callable(object)):
	for item in items:
		action(item)

def map(items, func as callable(object) as object):
	return func(item) for item in items

each(range(2)) def (x):
	print x

b = map(range(2), {x| x.toString() })
print b
