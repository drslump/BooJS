"""
0
string null
Array null
regex True
object 2
duck foo1
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
print 'list', f

r as regex = /foo/
print 'regex', r.test('foo')

# Objects are mutable in Javascript thus it's init as null
o as object = 1
o['foo']
print 'object', o + 1

# Duck type is mostly the same as object
p as duck = 'foo'
print 'duck', p + 1 

