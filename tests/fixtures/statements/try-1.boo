"""
caught!
should end up here!
"""
try:
	raise "caught!"
	print "should not get here!"
except x:
	print x.message
print "should end up here!"
