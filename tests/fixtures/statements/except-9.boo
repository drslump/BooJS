"""
TypeError: Foo
"""
try:
	raise TypeError('Foo')
except ex as TypeError:
	print 'TypeError: ' + ex.message
except ex:
	print 'Caught'
