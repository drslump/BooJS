a = [5, 4, 3, 2, 1]

def find(lst as int*, cb as callable):
	for i, v in enumerate(lst):
		return i if cb(v)
	return null

assert 0 == find(a, { item as int | return item > 3 })
assert 3 == find(a, { item as int | return item < 3 })
