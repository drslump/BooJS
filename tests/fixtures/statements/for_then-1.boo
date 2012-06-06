"""
We made it!
foo
"""

breaker = "none"

t = ("boo", "bar", "baz", "foo")

for item in t:
	found = item
	if item is breaker:
		break
then:
	print "We made it!"
	
print found