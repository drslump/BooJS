#IGNORE: Typesystem reflection not implemented yet
"""
class java.lang.IllegalStateException
"""
try:
	assert false
except x:
	print x.GetType()
	
assert true