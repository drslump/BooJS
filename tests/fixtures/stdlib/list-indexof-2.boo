a = [5, 4, 3, 2, 1]

def find(lst as int*, cb as ICallable):
	for i, v in enumerate(lst):
		return i if cb(v)
	return null

assert 0 == find(a as Array[of int], { item as int | return item > 3 })
assert 3 == find(a as Array[of int], { item as int | return item < 3 })
