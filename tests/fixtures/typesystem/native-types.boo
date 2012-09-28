"""
0
string null
list null
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

#e as List  # List type is not supported, only mutable arrays
#print e

# Arrays are mutable in Javascript thus it's init as null
f as list
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

