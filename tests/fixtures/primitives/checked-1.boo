#UNSUPPORTED: Checked arithmetic is not supported
"""
j: OverflowException
no exception and k is -2147483648
l: OverflowException
m1 was just fine
m2 still fine
n: OverflowException
no exception for o
p: OverflowException
"""

i = int.MaxValue

// numeric operations are checked by default
try:
	j = i + 1
	print "never gets here"
except x as System.OverflowException:
	print "j: OverflowException"

unchecked:
	k = i + 1
	print "no exception and k is ${k}"

	try:
		// reenable checking
		checked:
			l = i + 1
		print "never gets here"
	except x as System.OverflowException:
		print "l: OverflowException"		
		
	checked:
		
		unchecked:
			m1 = i + 1
			print "m1 was just fine"
			if true:
				m2 = i + 1
				print "m2 still fine"
				
			
		// back to checked block
		try:
			n = i + 1
			print "never gets here"
		except x as System.OverflowException:
			print "n: OverflowException"
			
	// back to unchecked block
	o = i + 1
	print "no exception for o"
	
// back to default/checked context
try:
	p = i + 1
	print "never gets here"
except x as System.OverflowException:
	print "p: OverflowException"

