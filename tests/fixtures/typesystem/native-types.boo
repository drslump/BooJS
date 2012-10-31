"""
0
string null
Array null
regex True
object null 1
duck FOO1 foo
"""

# Numbers are always initialized as 0
a as int
b as uint
c as double
print a + b + c

# Strings are mutable in Javascript thus it's init as null
d as string
print 'string', d

# Arrays are mutable in Javascript thus it's init as null
f as Array
print 'Array', f

r as regex = /foo/
print 'regex', r.test('foo')

# Objects are mutable in Javascript thus they are init as null
o1 as object
o2 as object = 1
print 'object', o1, o2

# Duck types behave the same as objects for type safety but also
# allow any operation on them (resolved at runtime).
p as duck = 'FOO'
print 'duck', p + 1, p.toLowerCase()
