#IGNORE: Slicing negative indices is not yet supported
"""
4
7
8
"""
a = ((1, 2), (3, 4), (5, 6), (7, 8))

print a[1][-1]
print a[-1][0]
print a[3][1]
