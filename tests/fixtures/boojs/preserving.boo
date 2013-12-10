"""
foo
50,20
"""

x = 'foo'
y = [10, 20]
preserving x, y[1]:
    x = 'bar'
    y[0] = 50
    y[1] = 60

print x
print y