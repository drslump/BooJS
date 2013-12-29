#IGNORE: Interfaces not supported yet
"""
FOO
"""
class StringList(Array[of string], string*):
	pass
	
ss = StringList()
ss.push("foo")
for s in ss:
	print s.toUpperCase()
