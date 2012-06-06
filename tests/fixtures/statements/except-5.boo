"""
TypeError
"""
try:
	raise TypeError()
except as RangeError:
	print 'RangeError'
except as TypeError:
	print 'TypeError'
except:
	print 'Caught'
