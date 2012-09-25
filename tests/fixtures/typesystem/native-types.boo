"""
0
string null 
array null
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
f as array
print 'array', f

# Objects are mutable in Javascript thus it's init as null
o as object = 1
print 'object', o + 1

z as duck = 'foo'
print 'duck', z + 1 