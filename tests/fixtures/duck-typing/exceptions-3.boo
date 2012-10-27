def stackTrace(code as callable()):
	try:
		code()
	except x:
		return x.toString()

s = stackTrace:
	cast(duck, 3).Foo()

// we expect to see line 3 and line 8 in there
assert 2 == len(/exceptions-3/.match(s))	
	
	
	

	
