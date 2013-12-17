"""
2
6
10
"""
def odds(l):
	for i as int in l:
		yield i if 0 != i % 2
		
def d(i as int):
	return i*2
	
def map(fn as callable, enumerable):
	for item in enumerable:
		yield fn(item)
		
for odd in map(d, odds([1, 2, 3, 4, 5])):
	print(odd)
