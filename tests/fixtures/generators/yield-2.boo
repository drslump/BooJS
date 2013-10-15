"""
1
2
3
"""

/*
def onetwothree():
	yield 1
	try:
		yield 2
		print 'AFTER'
	except e:
		print 'EXCEPT'
	ensure:
		print 'ENSURE'
	yield 3
*/	


def onetwothree():
	print 'one'
	yield 1
	i = 0
	while i < 5:
		yield i 
		i++
	print 'two'
	yield 2
	print 'three'
	yield 3
	print 'END'
	
for itm in onetwothree():
	print itm

/*	
idx = 0
e as duck = onetwothree()
while true:
	itm = e.next()
	print 'itm', itm
	break if idx++ > 10
*/