"""
Error: Foo
"""
try:
	raise TypeError('Foo')
except ex as RangeError:
	print 'RangeError'
except ex as Error:
	print 'Error: ' + ex.message
