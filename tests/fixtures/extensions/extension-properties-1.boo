#IGNORE: BUG - Static properties not supported yet
"""
StringExtensions.length
3
"""

class StringExtensions:
	[Extension]
	static count[s as string]:
		get:
			print "StringExtensions.length"
			return len(s)
			
print "FOO".count
