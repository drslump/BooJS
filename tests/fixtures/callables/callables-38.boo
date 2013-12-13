"""
0*2 = 0
1*2 = 2
2*2 = 4
"""
def each(items, action as callable(object)):
	for item in items:
		action(item)

def map(items, func as callable(object) as object):
	return func(item) for item in items
	
each(map(range(3), { item as int | return item, item*2 })) do (pair):
	x, y = pair
	print("${x}*2 = ${y}")
	
