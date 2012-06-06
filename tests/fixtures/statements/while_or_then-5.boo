"""
adding item: 4
Did we make it?
"""

list = [1, 2, 3, 4]

while len(list) < 5:
	print "adding item: $(len(list))"
	list.push(len(list))
	break if list.indexOf(3) >= 0
or:
	print "List already big!"
then:
	print "We made it!"
	
print "Did we make it?"