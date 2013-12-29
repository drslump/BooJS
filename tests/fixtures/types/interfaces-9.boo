#IGNORE: Interfaces not supported yet
"""
Foo
"""
interface IFoo:
	pass
	
class Foo(IFoo):
	pass
	
def use(foo as IFoo):
	print(foo.GetType())

use(Foo())
