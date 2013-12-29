#UNSUPPORTED: Meta programming not supported yet
"""
def foo(m as System.String):
	print(m)
"""
typeRef = string
print [|
	def foo(m as $typeRef):
		print(m)
|].ToCodeString()
