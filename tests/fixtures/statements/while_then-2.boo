"""
adding item: 0
adding item: 1
adding item: 2
adding item: 3
Did we make it?
"""

list = []

while len(list) < 5:
	print "adding item: $(len(list))"
	list.push(len(list))
	break if list.indexOf(3) >= 0
then:
	print "We finished!"
	
print "Did we make it?"