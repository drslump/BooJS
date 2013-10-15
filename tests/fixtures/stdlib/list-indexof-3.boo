# Values are compared by reference in BooJs unless we cast them to arrays
def find(list as Array, arr as (int)):
	for i, itm as (int) in enumerate(list):
		return i if itm == arr
	return -1

a = [(1, 2), (3, 4), (5, 6)]

assert 0 == find(a, (1, 2))
assert 1 == find(a, (3, 4))
assert -1 == find(a, (2, 1))
assert 2 == find(a, (5, 6))
