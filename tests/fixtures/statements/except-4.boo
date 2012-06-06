"""
RangeError
"""
try:
	raise RangeError()
except as RangeError:
	print 'RangeError'
except:
	print 'Caught'
