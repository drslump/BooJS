#IGNORE: BUG - Overloading breaks extension definitions
"""
Array.Each
Hello
interface
extensions
Iterable.Each
1
2
3
"""
[Extension]
def Each(e as Iterable, action as callable(object)):
	print "Iterable.Each"
	for item in e:
		action(item)
		
[Extension]
def Each(l as Array, action as callable(object)):
	print "Array.Each"
	for i in range(len(l)):
		action(l[i])
		
["Hello", "interface", "extensions"].Each(print)
(1, 2, 3).Each(print)
