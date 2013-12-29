"""
Iterable.Each
Hello
interface
extensions
"""
[Extension]
def Each(e as Iterable, action as callable(object)):
	print "Iterable.Each"
	for item in e:
		action(item)
		
["Hello", "interface", "extensions"].Each(print)
