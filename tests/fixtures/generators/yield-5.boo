"""
1 1
1 2
1 3
2 1
2 2
2 3
3 1
3 2
3 3
"""
def onetwothree():
	i = 0
	yield ++i
	yield ++i
	yield ++i
	
for i1 in onetwothree():
	for i2 in onetwothree():
		print("$i1 $i2")
