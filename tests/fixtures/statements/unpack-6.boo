"""
2
4
6
"""
a, b, c = { i *= 2; print i; return i }() for i in range(1, 4)
assert 2 == a
assert 4 == b
assert 6 == c
