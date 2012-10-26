"""
FOO
foo
"""
def ToUpper(s as string):
	return s.toUpperCase()
	
def ToLower(s as string):
	return s.toLowerCase()

def Select(upper as bool):	
	return ToUpper if upper
	return ToLower

a = "Foo"
print(Select(true)(a))
print(Select(false)(a))
