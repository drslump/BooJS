"""
True False True False True False
"""
a = not null
b = not a not in (1, 2, 3)
c = not a and b or a
d = not 10+10 > 5 and 3+4 < 3
e = not len([1]) == 0
f = not a and len([1]) == 0

print a, b, c, d, e, f
