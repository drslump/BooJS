#UNSUPPORTED: Meta programming not supported
"""
a = [|
	return 42
|]

b = [|
	while not foo:
		print 'bar'
|]
"""
a = [|
	return 42
|]

b = [|
	while not foo:
		print 'bar'
|]
