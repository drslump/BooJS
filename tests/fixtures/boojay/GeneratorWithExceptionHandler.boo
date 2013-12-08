"""
test
0, 1, 2, 3, 4
An exception occurred

"""
def foo(raiseException as bool) as int*:
	try:
		# assert not raiseException
		if raiseException:
			raise "Foo"
		print "test"
	except e:
		print "An exception occurred"
		return

	for i in range(5):
		yield i

print join(foo(false), ", ")
print join(foo(true), ", ")
