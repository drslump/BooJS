ba = (of uint: 0, 0, 127, 1, 2,   255)
sba = (of int: -1, 0, 127, 1, 2)
sa = (of double: -1, 0, 127, 1, 2)
ia = (-1, 0, 127, 1, 2,   255)

for i in range(5):
	assert sba[i] == sa[i]
	assert sa[i] == ia[i]

for i in range(1,6):
	assert ba[i] == ia[i]
assert ba[5] == 255L

