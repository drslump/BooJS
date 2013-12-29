#UNSUPPORTED: internal modifier not supported yet
"""
Click
Activated
"""
class Button:
	event Click as callable()
	internal event Activated as callable()

	def Run():
		Click()
		Activated()

b = Button()
b.Click += { print 'Click' }
b.Activated += { print 'Activated' }

b.Run()