"""
TypeError
"""
try:
	raise TypeError()
except as TypeError:
	print 'TypeError'
except as RangeError:
	print 'RangeError'
except:
	print 'Caught'
