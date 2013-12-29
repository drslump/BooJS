#UNSUPPORTED: GetEnumerator is not supported
"""
FOO
BAR
"""
[EnumeratorItemType(string)]
class Enumerable(System.Collections.IEnumerable):
	def GetEnumerator():
		return ("foo", "bar").GetEnumerator()
		
for s in Enumerable():
	print(s.toUpperCase()) # s is declared as System.String
