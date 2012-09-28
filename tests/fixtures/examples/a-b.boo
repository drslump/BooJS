"""
12
34
56
78
89
"""
data = (
	'1 2',
	'3 4',
	'5 6',
	'7 8',
	'8 9',
)

for ln in data:
	a, b = ln.split(' ')
	print a + b

