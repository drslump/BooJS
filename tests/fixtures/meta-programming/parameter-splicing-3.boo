#UNSUPPORTED: Meta programming not supported yet
"""
def foo(bar):
	pass
"""

name = "bar"
method = [|
	def foo($name):
		pass
|]
print method.ToCodeString()
