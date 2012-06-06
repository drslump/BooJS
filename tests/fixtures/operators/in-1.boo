"""
true
true
true
true
false
false
false
false
true
true
true
true
"""
l = [1, 2, 3]
h = { 1: "1", 2: "2" }
a = (1, 2, 3)
e = range(1, 3)

print 1 in l
print 1 in h
print 1 in a
print 1 in e

print 0 in l
print 0 in h
print 0 in a
print 0 in e

print 0 not in l
print 0 not in h
print 0 not in a
print 0 not in e
