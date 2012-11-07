def map(items as (int), func as callable):
	l = len(items)
	i = 0
	while i < l:
		yield func(items[i])
		i++
	#for item in items:
	#	yield func(item)
		
x2 = { value as int | return value*2 }
e = map(range(1, 4), x2)

assert e.next() == 2
assert e.next() == 4
assert e.next() == 6
