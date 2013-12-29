"""
before subscribers
nothing printed
clicked!
clicked!
clicked again!
clicked!
"""

class Button:
	event Click as callable(object, object)
	
	def RaiseClick():
		Click(self, null)
	
def click(sender, args as object):
	print("clicked again!")

b = Button()

print("before subscribers")
b.RaiseClick()
print("nothing printed")

b.Click += def (sender, args):
	print("clicked!")
	assert sender is b
	assert null is args
	
b.RaiseClick()

b.Click += click
b.RaiseClick()
	
b.Click -= click
b.RaiseClick()
