class X:
	public x = (0, 1, 2, 3, 4, 5, 6, 7, 8, 9)
class Y:
	public y = (0, 1, 2, 3, 4, 5, 6, 7, 8, 9) #same content

x = X()
y = Y()
assert len(x.x) == 10
assert len(y.y) == 10
for i in range(len(x.x)):
	assert x.x[i] == i
	assert x.x[i] == y.y[i]

a = (9,8,7,6,5,4,3,2,1,0)
b = (of uint: 9,8,7,6,5,4,3,2,1,0)
assert len(a) == 10
assert len(a) == len(b)
for i in range(len(a)):
	assert a[i] == 9-i
	assert a[i] == b[i]

