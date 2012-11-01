#IGNORE: loop declarations shadow locals
"""
1
2
3
1
2
3
"""

def foo(message):
	for message in message:
		print message
	for message in message:
		print message
		
foo(["1", "2", 3])
		
	
