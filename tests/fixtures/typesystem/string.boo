"""
foo bar
operators foobar foofoo
formatting foo-bar
True
toUpperCase FOO
charAt o
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
assert {x as string| x+x }(a) == 'foofoo'
assert { a + a }() == 'foofoo'

# Slicing
assert a[1] == 'o'
assert a[:2] == 'fo'
assert a[1:] == 'oo'
assert a[-2:] == 'oo'
assert a[0:3:2] == 'fo'
