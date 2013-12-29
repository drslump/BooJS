#UNSUPPORTED: Meta programming not supported yet
"""
class Foo:
	pass
"""
className = "Foo"
type = [|
	class $className:
		pass
|]
print type.ToCodeString()


