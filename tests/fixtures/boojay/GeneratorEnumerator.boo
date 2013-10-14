"""
A STRING
"""

def producer() as string*:
	yield "a string"

def consume(strings as string*):
	enumerator = strings.iterator()
	try:
		while true:	print enumerator.next().toUpperCase()
	except:
		pass
		
consume producer()