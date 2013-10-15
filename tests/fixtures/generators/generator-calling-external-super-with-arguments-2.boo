#IGNORE: Classes not supported
"""
B: foo!
B: bar!
"""
namespace Generators

import Boo.Lang.Compiler.MetaProgramming

class A:
	virtual def Foo(arg):
		yield "foo" + arg 
		yield "bar" + arg
	
code = [|

	import Generators
	
	class B(A):
		override def Foo(arg):
			for i in super(arg):
				yield "B: " + i
				
	for i in B().Foo("!"):
		print i
|]

compile(code, typeof(A).Assembly).EntryPoint.Invoke(null, (null,))
