"""
throw
caught exception; reraising
reraise successfull
"""
try:
	try:
		print "throw"
		raise "exception"
	except e:
		print "caught ${e.message}; reraising"
		raise
		print "reraise failed"
except:
	print "reraise successfull"

