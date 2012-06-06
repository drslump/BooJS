"""
Error
"""
try:
	raise RangeError()
except as TypeError:
	print 'TypeError'
except as Error:
	print 'Error'
