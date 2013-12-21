"""
drslump 33
"""
namespace Tests

class Foo:
	name as string
	age as int

	def constructor(name as string, age as int):
		self.name = name
		self.age = age

	def run():
		print name, age


f = Foo('drslump', 33)
f.run()