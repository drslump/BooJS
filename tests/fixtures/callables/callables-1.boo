#IGNORE: Callables not fully supported yet
"""
FOO
"""
class ToUpper(ICallable):
	def Call(args as (object)) as object:
		return cast(string, args[0]).toUpperCase()

a = ToUpper()
print(a("foo"))
