"""
error!
"""
try:
	raise "error!"
except x as Error:
	print x.message
