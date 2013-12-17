"""

"""
def iif(test, ok as callable, fail as callable):
	if test:
		return ok()
	else:
		return fail()

a = null
b = iif(a is null, { return "" }, { return a.toString() })
print b