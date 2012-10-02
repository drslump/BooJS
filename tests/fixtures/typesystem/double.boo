"""
arithmetic 13 8 26.25 4.2 0.5
unary -10.5 9.5 10.5 10.5 9.5
exponent 357.250830999733
toString 10.5
toFixed 10
"""
a as int = 10.5
b = 2.5  # type inference

# Arithmetic
print 'arithmetic', a + b, a - b, a * b, a / b, a % b

# Unary
print 'unary', -a, --a, ++a, a--, a++
assert a = 10.5

# Exponent
print 'exponent', a ** b

# Bitwise (TODO: Check that the operations produce a compilation error)
#print 'bitwise', a >> 2, b << 2, ~a, a & b, a | b, a ^ b

assert b < a
assert a > b
assert b <= a and a <= 10.5
assert a >= b and b >= 2.5
assert a == 10.5
assert a != b

# Methods
print 'toString', a.toString()
print 'toFixed', a.toFixed(0)

# Expression blocks
assert {x| x*x}(a) == 110.25
assert {a*a}() - b == 107.75
