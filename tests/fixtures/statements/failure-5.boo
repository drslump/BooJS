"""
Testing failure with uncaught exception, no ensure
failed
uncaught
"""

try:
	print "Testing failure with uncaught exception, no ensure"
	try:
		raise Error("WOW")
	except as TypeError:
		print "caught"
	failure:
		print "failed"
except:
	print "uncaught"
