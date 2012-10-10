"""
caught!
should have passed here first!
should end up here!

"""
	
try:
	raise TypeError("caught!")
	print "should not get here!"
except x:
	print x.message
ensure:
	print "should have passed here first!"
print "should end up here!"