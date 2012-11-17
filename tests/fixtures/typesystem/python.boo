[Extension] def append(arr as Array, itm as object):
    arr.push(itm)


# Extend the Hash object (a plain Javascript object actually) to support Python's
# dict API.

[extension] def iter(h as Hash):
	return h.keys()

[extension] def clear(h as Hash):
	for k in h.keys():
		`delete h[k]`

[extension] def copy(h as Hash):
	copy = {}
	for v, k in h:
		copy[k] = v
	return copy

[extension] def get_(h as Hash, key as object):
	return (h[key] if key in h else null)
[extension] def get_(h as Hash, key as object, default as object):
	return (h[key] if key in h else default)

[extension] def has_key(h as Hash, key as object):
	return key in h

/*
[extension] def iteritems(h as Hash):
	return Boo.generator(h.items())
[extension] def iterkeys(h as Hash):
	return Boo.generator(h.keys())
[extension] def itervalues(h as Hash):
	return Boo.generator(h.values())
*/

[extension] def pop(h as Hash):
	pair = h.popitem()
	if pair is not null:
		return pair[0]
	return null

[extension] def popitem(h as Hash):
	_keys = h.keys()
	if len(_keys):
		key = _keys.pop()
		pair = [key, h[key]]
		`delete h[key]`
		return pair
	return null

[extension] def update(h as Hash, data as Hash):
	for v, k in data:
		h[k] = v

def dict():
	return {}
def dict(params as Hash):
	return params

d = dict(foo: 'Foo', bar: 'Bar')
d.update(bar: 'BAR', baz: 'BAZ')
print d



mylist = []
mylist.append(1)
mylist.append(2)
mylist.append(3)
print(mylist[0]) # prints 1
print(mylist[1]) # prints 2
print(mylist[2]) # prints 3

# prints out 1,2,3
for x in mylist:
    print x
