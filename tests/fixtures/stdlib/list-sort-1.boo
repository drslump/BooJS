

l = [2, 4, 3, 5, 1]
assert l.sort() == [1, 2, 3, 4, 5]
assert l.sort({ lhs as int, rhs as int | return rhs - lhs }) == [5, 4, 3, 2, 1]
