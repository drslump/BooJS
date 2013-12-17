"""
1 4
1 5
1 6
2 4
2 5
2 6
3 4
3 5
3 6
---
1 1
1 3
3 1
3 3
"""
a = (x, y) for x in (1, 2, 3) for y in (4, 5, 6)
b = [(x, y) for x in range(4) if x % 2 for y in range(5) if y % 2]

for x, y in a:
	print x, y

print '---'

for x, y in b:
	print x, y
