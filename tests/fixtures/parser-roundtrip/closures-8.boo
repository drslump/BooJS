"""
"""
predicate = def (item as int):
	return 0 == item % 2

assert true == predicate(10)
assert false == predicate(11)
