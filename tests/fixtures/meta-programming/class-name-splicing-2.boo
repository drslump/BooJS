#UNSUPPORTED: Meta programming not supported yet
"""
class Foo(Base):
	pass
"""
className = "Foo"
type = [|
	class $className(Base):
		pass
|]
print type.ToCodeString()


