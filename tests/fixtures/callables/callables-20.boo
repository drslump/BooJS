"""
Testing...
"""
callable OutputHandler(message as string)

def print(message as string):
	global console
	console.log(message)
	
handler as OutputHandler
handler = print
handler("Testing...")
