"""
Caught: Foo
"""
try:
	raise TypeError('Foo')
except ex:
	print 'Caught: ' + ex.message
