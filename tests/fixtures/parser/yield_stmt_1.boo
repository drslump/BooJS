"""
1
3
5
7
9
"""
def odds(l):
	for i as int in l:
		yield i if 0 != i % 2

for n in odds(range(10)):
	print n
