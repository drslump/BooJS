#IGNORE: Generator expressions are optimized in BooJs and directly converted to arrays

a = range(3)
g = i*2 for i in a
assert "0 2 4" == join(g)

a = range(3, 6)
assert "6 8 10" == join(g)
