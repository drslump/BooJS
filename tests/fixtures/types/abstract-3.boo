#IGNORE: BUG - Inherit from imported type is not correctly mapped
from BooJs.Tests.Support import AbstractClass

class Concrete(AbstractClass):

	[property(Token)] _token = null
	
	override def toString():
		return "${_token}"
	
c = Concrete(Token: "Hello!")
assert "Hello!" == c.Token
