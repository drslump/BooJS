"""
1
2
3
abc
"""

items = [(1, 0), (3, 0), (2, 0)]
items.sort()

for a, b in items:
	print a

items = [(1, "c"), (1, "b"), (1, "a")]
items.sort()

for a, b in items:
	print b


