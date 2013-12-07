"""
1
2
3
"""
def onetwothree():
	yield 1
	yield 2
	yield 3
	
e = onetwothree().iterator()
for itm in e:
	print itm
