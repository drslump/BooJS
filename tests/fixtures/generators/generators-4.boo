#IGNORE: Generator expressions are optimized in BooJs and directly converted to arrays
"""
0 4 8 12 16
0 4 8 12 16
"""

generator = i*2 for i in range(10) if 0 == i % 2

e1 = generator.iterator()
e2 = generator.iterator()
assert e1 is not e2, "GeneratorIterator instances must be distintic!"

for i in 0, 4, 8, 12, 16:
	assert i == e1.next()
	assert i == e2.next()

print(join(generator))
print(join(generator))

