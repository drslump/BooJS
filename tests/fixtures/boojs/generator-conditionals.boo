"""
lower, end
medium, end
higher, end
unless, end
end
"""

def gen_if(x as int):
	if x < 10:
		yield "lower"
	elif x < 20:
		yield "medium"
	else:
		yield "higher"

	yield 'end'


def gen_unless(x as int):
	unless x < 10:
		yield "unless"
	yield 'end'


print join(gen_if(5), ', ')
print join(gen_if(15), ', ')
print join(gen_if(25), ', ')

print join(gen_unless(5), ', ')
print join(gen_unless(25), ', ')
