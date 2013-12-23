#IGNORE: BUG - Base type reference should take into account imported namespace mapping
"""
BaseClass.Method0
A.Method0
BaseClass.Method0

"""
from BooJs.Tests.Support import BaseClass

class A(BaseClass):
	def Method0():
		super()
		print("A.Method0") #overriden method
		super() #base class method
		
b as BaseClass = A()
b.Method0()

