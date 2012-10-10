"""
19 23
42
"""

def sysout(i as int, j as int):
	print i, j
	global console
	console.log(i + j)
	
sysout 19, 23