"""
reraise
ensure
caught: foo
"""

def foo():
	try:
		raise Error("foo")
	except x:
		print "reraise"
		raise
	ensure:
		print "ensure"
		
try:
	foo()
except x:
	print "caught:", x.message