"""
loop: 3
"""

def mean(lst as int*):
	sum = 0
	for itm in lst:
		sum += itm
	return (sum / len(lst) if len(lst) else 0)
 
items = [1, 2, 3, 4, 5]
print 'loop:', mean(items)
#print 'reduce:', reduce(items, {a as int, b as int| a+b}) / len(items)
