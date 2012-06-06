"""
Good
"""
def RetVal():
	return 5
	
try:
	raise Error()
except as Error unless RetVal() >= 4:
	print "What?"
except as Error if RetVal().toString() == "5":
	print "Good"
except as Error:
	print "NO!"
