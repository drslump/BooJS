"""
foo = 3
key = value
foo = 3
key = value
foo = 3
key = value
key
foo
value
3
"""
h = { "key" : "value", "foo": 3 }

# Literal hashes are mapped to simple Javascript objects
for key, value in [(k, v) for k, v in h].sort():
    print key, '=', value

# We can also use enumerate to get an array of (k, v) pairs
for key, value in enumerate(h).sort():
    print key, '=', value
	
# .items() is an alias to enumerate(h)
for key, value in h.items().sort():
	print key, '=', value

# .keys() obtains only the keys
for key in h.keys():
	print key

# .values() obtains only the keys
for value in h.values():
    print value
