"""
"""
a = array(int, range(3, 0))
b = (cast(int, 3), cast(int, 2), cast(int, 1))

assert a == b

l = [3, 2, 1]
assert a == array(int, l)

c = array(double, range(3, 0))
d = (3.0, 2.0, 1.0)

assert c == d
assert c == array(double, (3, 2, 1))
assert c == array(double, [3, 2, 1])
