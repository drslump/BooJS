"""
0
2
4
"""

closures = []
for i in range(3):
	closures.push({i * 2})

for fn as callable in closures:
	print fn()