"""
10 20
10 foo
"""

def Method[of T1, T2](x as T1, y as T2):
	print x, y


Method[of int, int](10, 20)
Method[of int, string](10, 'foo')