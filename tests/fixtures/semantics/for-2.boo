#IGNORE: Classes not supported yet

class Foo (IEnumerable):
	def IEnumerable.GetEnumerator() as IEnumerator:
		return InternalEnumerator()

	class InternalEnumerator (IEnumerator):
		i = 0

		def IEnumerator.MoveNext():
			i++
			return true if i == 1

		IEnumerator.Current as object:
			get:
				return "foo"

		def IEnumerator.Reset():
			pass


for i in Foo(): #NO DISPOSE IS REQUIRED
	print i

