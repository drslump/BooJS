#UNSUPPORTED: Reflection not supported yet
"""
class java.lang.IllegalStateException
"""
try:
	assert false
except x:
	print x.GetType()
	
assert true