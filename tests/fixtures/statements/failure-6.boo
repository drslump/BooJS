"""
Testing failure without ensure or catch
failed
uncaught
"""

try:
	print "Testing failure without ensure or catch"
	try:
		raise Error()
	failure:
		print "failed"
except:
	print "uncaught"
