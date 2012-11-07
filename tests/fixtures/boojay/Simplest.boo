"""
before
in between
after
"""

def simplest():
	print "before"
	yield null
	print "after"
	
for item in simplest():
	print "in between"