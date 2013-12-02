"""
0, 1, 2, 3, 4, end
1, 2, 3, end
5, 4, 3, 2, 1, 0, end
"""

def gen_for(iter):
	for x in iter:
		yield x

	yield 'end'


def gen_while(x as int):
	while x >= 0:
		yield x 
		x -= 1
	yield 'end'


print join(gen_for(range(5)), ', ')
print join(gen_for([1,2,3]), ', ')

print join(gen_while(5), ', ')
