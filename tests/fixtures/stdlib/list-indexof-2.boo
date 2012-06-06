a = [5, 4, 3, 2, 1]
	
assert 0 == a.indexOf({ item as int | return item > 3 })
assert 3 == a.indexOf({ item as int | return item < 3 })
