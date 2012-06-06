"""
TypeError: Foo
"""
try:
	raise TypeError('Foo')
except ex as TypeError:
	print 'TypeError: ' + ex.message
except ex as RangeError:
	print 'RangeError'
except ex:
	print 'Caught'
