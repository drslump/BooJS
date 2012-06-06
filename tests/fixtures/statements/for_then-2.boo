"""
foo
"""

breaker = "foo"

t = ("boo", "bar", "baz", "foo")

for item as string in t:
	found = item
	if item is breaker:
		break
then:
	print "We shouldn't be here!"
	
print found