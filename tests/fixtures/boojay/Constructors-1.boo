#IGNORE: Super not supported yet
"""
John Cleese
"""

class Named:
	public name as string
	def constructor(name as string):
		self.name = name
		
class Person(Named):
	def constructor(name as string):
		super(name)
		
class Printer:
	def print(line as string):
		print line

funnyGuy = Person("John Cleese")
Printer().print(funnyGuy.name)