"""
Hello Extension Methods
"""
[Extension]
def ToTitle(s as string):
	return join(word[:1].toUpperCase() + word[1:] for word in s.split(char(' ')))
	
print "hello extension methods".ToTitle()
