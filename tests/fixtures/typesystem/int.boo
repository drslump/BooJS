"""
arithmetic 12 8 20 5 0
unary -10 9 10 10 9
exponent 100
bitwise 2 8 -11 2 10 8
toString 10
expression 100
expression 98
"""
a as int = 10
b = 2  # type inference

# Arithmetic
print 'arithmetic', a + b, a - b, a * b, a / b, a % b

# Unary
print 'unary', -a, --a, ++a, a--, a++
assert a = 10

# Exponent
print 'exponent', a ** b

# Bitwise
print 'bitwise', a >> 2, b << 2, ~a, a & b, a | b, a ^ b

assert b < a
assert a > b
assert b <= a and a <= 10
assert a >= b and b >= 2
assert a == 10
assert a != b

# Methods
print 'toString', a.toString()

# Expression blocks
{x| print('expression', x*x)}(a)
print 'expression', {a*a}() - b 
