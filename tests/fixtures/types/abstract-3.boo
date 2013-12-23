#IGNORE: Properties not supported yet
from BooJs.Tests.Support import AbstractClass

class Concrete(AbstractClass):

	[property(Token)] _token = null
	
	override def ToString():
		return "${_token}"
	
c = Concrete(Token: "Hello!")
assert "Hello!" == c.Token
