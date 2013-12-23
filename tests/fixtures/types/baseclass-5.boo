#IGNORE: BUG - Base type reference should take into account imported namespace mapping
"""
A.Method0
BaseClass.Method1
"""

from BooJs.Tests.Support import DerivedClass

class A(DerivedClass):
	def Method0():
		print("A.Method0") #overriden method	
	
		
a = A()
a.Method2() # see DerivedClass.Method2 for details
