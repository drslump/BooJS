#IGNORE: Lists are compared by reference in BooJs
a = [(1, 2), (3, 4), (5, 6)]

assert 0 == a.indexOf((1, 2))
assert 1 == a.indexOf((3, 4))
assert -1 == a.indexOf((2, 1))
assert 2 == a.indexOf((5, 6))
