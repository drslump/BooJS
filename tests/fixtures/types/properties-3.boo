"""
null reference
"""
class Person:
	Name as string:
		get:
			return null

try:
	# make sure the getter is typed string by
	# calling toLowerCase
	print(Person().Name.toLowerCase())
except x as TypeError:
	print("null reference")
