"""
ensure
caught: foo
"""
def foo():
	try:
		raise Error("foo")
	ensure:
		print "ensure"
		
try:
	foo()
except x:
	print "caught:", x.message