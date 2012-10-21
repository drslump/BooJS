"""
foo 100
foo 100
foo 100
"""
def foo(*args):
	print args[0], args[1]

{x| print 'foo', x}(100)
{x| foo('foo', x)}(100)
{x| foo(*('foo', x))}(100)
