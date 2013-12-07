
functions = Math.sin, Math.cos

generators = []
for f in functions:
	generators.push(f(value) for value in range(3))

for generator, func as callable(double) as double in zip(generators, functions):
	expected = join(func(i) for i in range(3))
	actual = join(generator)
	assert expected == actual
