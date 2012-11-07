"""
A STRING
"""

def producer() as string*:
	yield "a string"

def consume(strings as string*):
	enumerator = strings
	try:
		while true:	print enumerator.next().toUpperCase()
	except:
		pass
		
consume producer()