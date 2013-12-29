#UNSUPPORTED: Meta programming not supported
"""
a = [|
	print 'foo'
|]

b = [|
	System.Console.WriteLine('foo')
	System.Console.WriteLine('bar')
|]
"""
a = [|
	print 'foo'
|]

b = [|
	System.Console.WriteLine('foo')
	System.Console.WriteLine('bar')
|]
