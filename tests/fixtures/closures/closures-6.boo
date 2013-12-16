
def filter(items, condition as callable(object)):
	return [item for item in items if condition(item)]

even = filter(range(10), { item as int | return 0 == item % 2 })
assert even == [0, 2, 4, 6, 8]

