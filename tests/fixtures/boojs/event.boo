"""
Start
Handler(10)
Click with value: 10
Click with value: 20
Stop
"""
class Foo:
	event Click as callable(int)

	def ClickIt(x):
		Click(x) if Click


def handler(x):
	print "Handler($x)"


print "Start"

f = Foo()
f.Click += handler
f.Click += def (x):
	print "Click with value: $x"

f.ClickIt(10)

f.Click -= handler
f.ClickIt(20)

print "Stop"
