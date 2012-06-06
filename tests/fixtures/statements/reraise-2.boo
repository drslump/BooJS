"""
throw
caught something; reraising
reraise successfull
caught exception; reraising
reraise successfull
"""
try:
	try:
		try:
			print "throw"
			raise "exception"			
		except:
			print "caught something; reraising"
			raise
			print "reraise failed"
	except e:
		print "reraise successfull"
		print "caught ${e.message}; reraising"
		raise
		print "reraise failed"
except:
	print "reraise successfull"

