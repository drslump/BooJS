#IGNORE: BUG - Slicing to get a reverse [::-1]
"""
"""
l = [1, 2, 3]
assert 1 == l[0]
assert 2 == l[1]
assert l[:2] == [1, 2]
assert l[0:1] == [1]
assert l[:1] == [1]
assert 3 == l[-1]
assert l[1:] == [2, 3]
assert l[::-1] == [3, 2, 1]
assert l[:] == [1, 2, 3]
assert l[::2] == [1, 3] 
