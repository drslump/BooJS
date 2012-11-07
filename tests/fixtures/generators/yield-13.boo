def generator() as object*:
	yield 1
	yield "um"
	
assert "1: um" == join(generator(), ": ")
