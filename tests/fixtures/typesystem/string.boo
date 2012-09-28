"""
foo bar
operators foobar foofoo
formatting foo-bar
True
toUpperCase FOO
charAt o
expression foofoo
expression foofoobar
"""
a as string = 'foo'
b = 'bar'  # Type inference

print a, b
print 'operators', a + b, a * 2

# Formatting
print "formatting {0}-{1}" % (a, b)

# Bool
if a: print true
if not a: print false
if '': print 'empty'

# Logic
assert a == 'foo'
assert a != b

# Methods
print 'toUpperCase', a.toUpperCase()
print 'charAt', a.charAt(1)

# Expression blocks
{x as string| print('expression', x+x)}(a)
print 'expression', {return cast(string, a+a)}()  # TODO: Inference not working!!!
