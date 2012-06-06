"""
got here first!
nested!
first!
second!
"""
#import System

try:	
	raise "got here first!" #ApplicationException("got here first!")
	print "never here!"
except x: # as ApplicationException:
	print x.message
	try:
		raise "nested!" #ApplicationException("nested!")
	except x:
		print x.message
	ensure:
		print "first!"
ensure:
	print "second!"
