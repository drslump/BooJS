"""
Default
"""
try:
	raise Error()
except as TypeError:
	print 'TypeError'
except:
	print 'Default'
