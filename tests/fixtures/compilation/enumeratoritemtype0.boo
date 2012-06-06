"""
FOO
BAR
"""
for s in "foo\nbar".split("\n"): #System.IO.StringReader("foo\nbar"):
	print s.toUpperCase() # s is declared as System.String
