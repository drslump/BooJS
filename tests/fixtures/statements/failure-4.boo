"""
Testing failure with caught exception, no ensure
caught
"""
 
def RetVal():
	return 5

try:
	print "Testing failure with caught exception, no ensure"
	try:
		raise Error()
	except if RetVal() == 5:
		print "caught"
	failure:
		print "failed"
except:
	print "uncaught"
