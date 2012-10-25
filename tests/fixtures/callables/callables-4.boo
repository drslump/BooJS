"""
0 2 4 6 8
"""
def even(value):	
	return 0 == cast(int, value) % 2

print(join(filter(range(10), even)))
