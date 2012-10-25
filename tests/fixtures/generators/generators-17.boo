

functions = Math.sin, Math.cos

generators = []
for f in functions:
	generators.push(f(value) for value in range(3))

for generator, function as callable(double) as double in zip(generators, functions):
	expected = join(function(i) for i in range(3))
	actual = join(generator)
	assert expected == actual
