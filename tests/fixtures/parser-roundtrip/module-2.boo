"""
x = 10, y = 20
30
"""
namespace Math

def square(x as int) as int:
	return x*x

def add(x as int, y as int) as int:
	print("x = {0}, y = {1}" % (x, y))
	return x + y

print add(10, 20)