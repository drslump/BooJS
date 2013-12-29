#IGNORE: BUG - Overloading breaks extension definitions
"""
op_Equality(self as string, rhs as char)
True
op_Equality(self as string, rhs as char)
False
op_Equality(self as char, rhs as string)
op_Equality(self as string, rhs as char)
True
"""
[Extension]
internal def op_Equality(lhs as string, rhs as int):
	print "op_Equality(self as string, rhs as int)"
	return len(lhs) == 1 and lhs.charCodeAt(0) == rhs
	
[Extension]
internal def op_Equality(lhs as int, rhs as string):
	print "op_Equality(self as int, rhs as string)"
	return rhs == lhs
	
print "a" == 65
print "ab" == 65
print 65 == "a"

