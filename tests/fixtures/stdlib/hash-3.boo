"""
foo = 3
key = value
"""
h = { "key" : "value", "foo": 3 }

#for key, value in [(item.Key, item.Value) for item in h].Sort():
#	print key, "=", value

# We can also use enumerate to get an array of (k, v) pairs
for key, value in enumerate(h).sort():
	print key, '=', value
	
# BooJs aliases Hash.iter() to enumerate at compile time
for key, value in h.items().sort():
	print key, '=', value
