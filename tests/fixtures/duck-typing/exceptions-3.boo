def stackTrace(code as callable()):
	try:
		code()
	except x:
		return x.toString()

s = stackTrace:
	s as duck = 3
	s.Foo()

// we expect to see line 3 and line 8 in there
assert 'TypeError' == /TypeError/.exec(s)
	
	
	

	
