"""
toUpperCase
BOO
"""
[Extension]
def toUpperCase(s as string, beginIndex as int, endIndex as int):
	print "toUpperCase"
	return s[beginIndex:endIndex].toUpperCase()
	
print "zaboomba".toUpperCase(2, 5)
