"""
42
"""

def trace(s as string):
	builder = Array()
	builder.push(s) # must be able to ignore value on the stack
	print builder.join("\n")
	
trace("42")