"""
clicked!
clicked!
"""
import BooJs.Tests.Support

def clicked(sender):
	print("clicked!")

c = Clickable(Click: clicked)
c.RaiseClick()
c.RaiseClick()
