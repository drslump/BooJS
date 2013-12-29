#UNSUPPORTED: Inner classes
"""
Outer+Inner.Foo
"""
class Outer:
	class Inner:
		static def Foo():
			print("${Inner}.Foo")

Outer.Inner.Foo()
