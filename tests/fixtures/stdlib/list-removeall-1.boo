# NOTE: Javascript array's filter works the inverse to Boo's one
a = [1, 2, 3, 4, 5, 6]
a = a.filter({item as int | return 1 == item % 2})
assert a == [1, 3, 5]
a = [2, 4, 6, 8]
a = a.filter({item as int | return 1 == item % 2})
assert a == []
