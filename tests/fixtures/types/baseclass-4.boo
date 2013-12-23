#IGNORE: BUG - Base type reference should take into account imported namespace mapping
"""
BaseClass.constructor('Hello!')
BaseClass.Method0

"""
from BooJs.Tests.Support import BaseClass

class A(BaseClass):
	def constructor():
		super('Hello!')
		
b as BaseClass = A()
b.Method0()

