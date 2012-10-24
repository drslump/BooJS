"""
0 1 2
continue 2
break 0
return 11
"""

def loop_with_return():
	for i in range(3):
		return i if i > 0

res = []
for i in range(3):
	res.push(i)

print join(res, ' ')

for i in range(3):
	if i < 2: continue
	print 'continue', i

for i in range(3):
	if i > 0: break
	print 'break', i

print 'return', loop_with_return() + 10
