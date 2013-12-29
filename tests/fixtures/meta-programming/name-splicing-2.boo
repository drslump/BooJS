#UNSUPPORTED: Meta programming not supported yet
"""
class Foo:

	public bar as string
"""
className = "Foo"
fieldName = "bar"
type = [|
	class $className:
		public $fieldName as string
|]
print type.ToCodeString()


