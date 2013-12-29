#UNSUPPORTED: Interfaces not supported yet
"""
"""

interface IFoo:
	def get() as object
	def set(value)

class Foo(IFoo):
	def get():
		return null
	def set(value):
		pass
		
Foo().set("")
Foo().get()

