#UNSUPPORTED: Meta programming not supported yet
"""
enum Foo:

	Bar
"""
member = [| Bar |]
type = [|
	enum Foo:
		$member
|]
print type.ToCodeString()
