h = Hash((i, i*2) for i in range(5))

assert len(h) == 5
assert h.keys().sort() == ['0', '1', '2', '3', '4']
assert h.values().sort() == [0, 2, 4, 6, 8]

for i in range(5):
	assert h[i] == i*2
