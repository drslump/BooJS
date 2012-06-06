"""
1 12 42 64
"""
a = (42, 12, 1, 64)
a.sort(a, { l as int, r as int | l - r })
print join(a)
