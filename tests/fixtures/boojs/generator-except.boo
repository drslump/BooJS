"""
10
Error: FooError
"""

def gen():
	try:
		yield 10
		raise Error('FooError')
		yield 20
	except e:
		print e

for i in gen():
	print i