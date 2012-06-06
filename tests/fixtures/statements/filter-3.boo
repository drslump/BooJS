"""
Good
This is the message
"""

def RetVal(toggle as bool):
	return not toggle

try:
	raise Error("This is the message")
except ex as Error if 1 == 2:
	print "What?"
	print ex.message
except ex as Error unless 1 == 1:
	print "Still Bad..."
	print ex.message
except ex as Error unless 1 == 2:
	print "Good"
	print ex.message
except ex as Error:
	print "NO!"
	print ex.message
