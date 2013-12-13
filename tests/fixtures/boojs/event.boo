#IGNORE: Events not supported yet
class Foo:
	event Click as callable()

	def ClickIt():
		Click() if Click

f = Foo()
f.Click += def (x):
	print x

f.ClickIt()
