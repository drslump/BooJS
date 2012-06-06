values = []
for i in range(10):
	break if i > 4
	values.push(i)
	
assert values[0] == 0
assert values[1] == 1
assert values[2] == 2
assert values[3] == 3
assert values[4] == 4
