#[Extension] def append(arr as Array, itm as object):
#    arr.push(itm)


# Extend the Hash object (a plain Javascript object actually) to support Python's
# dict API.

[extension] def @get(h as Hash, k as object):
	return (h[k] if k in h else null)
[extension] def @get2(h as Hash, k as object, deflt as object):
	return (h[k] if k in h else deflt)

[extension] def iter(h as Hash):
	return h.keys()

[extension] def clear(h as Hash):
	for k in h.keys():
		`delete h[k]`

[extension] def copy(h as Hash):
	copy = {}
	for k in h:
		`copy[k] = h[k]`
	return copy

[extension] def has_key(h as Hash, key as object):
	return key in h

[extension] def iteritems(h as Hash):
	return itm for itm in h.items()
[extension] def iterkeys(h as Hash):
	return key for key in h.keys()
[extension] def itervalues(h as Hash):
	return val for val in h.values()

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
	for k in data:
		h[k] = data[k]

def dict():
	return Hash()
def dict(params as Hash):
	return params

d = dict(foo: 'Foo', bar: 'Bar')
d.update(bar: 'BAR', baz: 'BAZ')
print d

/*
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
*/