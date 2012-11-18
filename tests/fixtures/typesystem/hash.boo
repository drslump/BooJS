"""
FOO
foo
BAR
bar
FOO
FOO
foo,bar,baz
FOO,BAR,BAZ
foo,FOO,bar,BAR,baz,BAZ
foo
bar
baz
foo FOO
bar BAR
baz BAZ
"""
h = {'foo': 'FOO', 'bar': 'BAR', 'baz': 'BAZ'}
print h['foo']
h['foo'] = 'foo'
print h['foo']

print h.bar
h.bar = 'bar'
print h.bar

h1 = Hash(foo: 'FOO', bar: 'BAR', baz: 'BAZ')
print h1['foo']
print h1.foo

print h.keys()
print h1.values()
print h1.items()

for key in h1:
	print key
for key, value in h1:
	print key, value

