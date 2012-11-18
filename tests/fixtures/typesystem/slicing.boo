a = (0, 1, 2, 3, 4, 5, 6, 7, 8, 9)

assert a[0] == 0
assert a[3] == 3
idx = 5
assert a[idx] == 5

assert a[-1] == 9
assert a[-3] == 7
idx = -2
assert a[idx] == 8
idx = 5
assert a[-idx] == 5

assert a[1:3] == (1, 2)
assert a[-3:] == (7, 8, 9)
assert a[1:6:2] == (1,3,5)

assert a[:2] == (0, 1) 
assert a[-3::2] == (7, 9)

# Slice on slice
b = ( (0.1, 0.2), (1.1, 1.2, 1.3), (2.1, 2.2) )
assert b[-1][-1] == 2.2
# TODO: Since we now use generics for slice the [0] breaks because it resolves the target
#       to a Generic.IEnumerable and that type doesn't offer slicing
#assert b[1:][-1:][0][-1] == 2.2
