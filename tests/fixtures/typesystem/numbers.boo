"""
0.1
-99.9
50.1
"""
i as int = -10
u as uint = 10
d as double = 0.10

print i + u + d
print i * u + d

# Check conversion from string
s as string = '5'
print u * (s cast int) + d
