"""
>FOO
>BAR
null
"""
#NOTE: In Boo the last line would be "bar", since the loop reuses the variable
def test(items as object*):
	s as string
	for s in items:
		print ">$s".toUpperCase()
	print s

test(["foo", "bar"])
