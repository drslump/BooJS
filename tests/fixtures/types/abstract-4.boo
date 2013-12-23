#IGNORE: BUG - Base type reference should take into account imported namespace mapping

from BooJs.Tests.Support import AnotherAbstractClass

class Concrete(AnotherAbstractClass):

	override def Foo():
		return "Concrete.Foo"
		
	override def Bar():
		return "Concrete.Bar"
	
c = Concrete()
assert "Concrete.Foo" == c.Foo()
assert "Concrete.Bar" == c.Bar()
