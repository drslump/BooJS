#IGNORE: BUG - Base type reference should take into account imported namespace mapping
"""
BaseClass.Method0
BaseClass.Method1
"""
from BooJs.Tests.Support import BaseClass

class A(BaseClass):
	def constructor():
		self.Method0()
		
a = A()
a.Method1()
