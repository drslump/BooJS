"""
10
foo
"""

def Method[of T](t as T):
	print t


Method[of int](10)
Method[of string]('foo')
