"""
Testing failure with uncaught exception
failed
ensured
uncaught
"""

try:
	print "Testing failure with uncaught exception"
	try:
		raise Error("WOW")
	except as TypeError:
		print "caught"
	failure:
		print "failed"
	ensure:
		print "ensured"
except:
	print "uncaught"
