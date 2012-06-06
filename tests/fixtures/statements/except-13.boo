"""
Caught: Foo
"""
try:
	raise SyntaxError('Foo')
except ex as RangeError:
	print 'RangeError'
except ex as TypeError:
	print 'TypeError'
except ex:
	print 'Caught: ' + ex.message
