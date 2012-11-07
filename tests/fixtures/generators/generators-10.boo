#NOTE: In BooJS generator expressions are resolved immediately
"""
before generator
gen
after generator
before iteration
0
1
after iteration
"""
def gen():
	print("gen")
	return range(2)
	
print("before generator")
a = i for i in gen()
print("after generator")

print("before iteration")
for i in a:
	print(i)
print("after iteration")
