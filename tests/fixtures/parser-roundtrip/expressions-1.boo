"""
10 1
1 30
-1 1
-11 -2
2 False
0
"""
a = 3 + 2 + 5
b = c = 1
d = 3 + a * 2 + (4 + int(a))/2
e = -1
g = -1 + 2
h = -(3*2 + 5)
i = -1*2
j = 3*2/3
k = i > j >> 2 + 3
l = i << 3 * 2 > j >> 2 + 3
l >>= 2
l <<= 2

print a, b
print c, d
print e, g
print h, i
print j, k
print l
