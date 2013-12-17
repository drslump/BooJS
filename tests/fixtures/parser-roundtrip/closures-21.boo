"""
"""
a = { x as int | x > 0 }
b = { x as int | x > 0 and x < 10 }
c = { x as int | x - 1 }

assert true == a(10)
assert false == b(15)
assert 9 == c(10)
