"""
Range caught
"""
try:
	raise RangeError()
except as RangeError:
	print 'Range caught'
except:
	print 'Caught'
