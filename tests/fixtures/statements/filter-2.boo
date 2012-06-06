"""
Good
This is the message
"""
def RetVal():
	return 5
	
try:
	raise Error("This is the message")
except ex as Error if RetVal() >= 4 and ex.message != "This is the message":
	print "What?"
	print ex.message
except ex as Error unless RetVal().toString() == "4":
	print "Good"
	print ex.message
except ex as Error:
	print "NO!"
	print ex.message
