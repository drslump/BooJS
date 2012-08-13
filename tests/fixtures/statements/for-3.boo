#IGNORE unpacking in loops is overloaded to: for v, k in hash
"""
1, 2
3, 4

"""

#for first, second in List().Add(List().Add(1).Add(2)).Add(List().Add(3).Add(4)):
for first, second in [ [1,2], [3,4] ]:	
	print "${first}, ${second}"
