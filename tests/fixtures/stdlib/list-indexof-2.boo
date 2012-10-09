a = [5, 4, 3, 2, 1]

def find(lst, cb as callable):
	for i in lst:
		return i if cb(i)
	return null

assert 0 == find(a, { item as int | return item > 3 })
assert 3 == find(a, { item as int | return item < 3 })
