"""
MakeItUpper:foo:FOO
MakeItLower:BaR:bar
"""

def upper(s as string):
	return s.toUpperCase()
	
def lower(s as string):
	return s.toLowerCase()
	
def invoke(fn as ICallable, arg):
	return fn(arg)
	
commandMap = {
				"MakeItUpper" : upper,
				"MakeItLower" : lower
			}
			
text = """
MakeItUpper foo FOO
MakeItLower BaR bar
"""

for line in /\n/.split(text):
	continue unless len(line.trim())	
	
	command, arg, expected = /\s+/.split(line)	
	assert expected == invoke(commandMap[command], arg)
	
	print("${command}:${arg}:${expected}")
