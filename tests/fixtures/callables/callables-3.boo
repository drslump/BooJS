"""
FOO
foo
"""
def ToUpper(s as string):
	return s.toUpperCase()
	
def ToLower(s as string):
	return s.toLowerCase()

def Transform(s, upper as bool):
	if upper:
		t = ToUpper
	else:
		t = ToLower
	return t(s)

a = "Foo"
print(Transform(a, true))
print(Transform(a, false))

