#IGNORE: Events not supported yet
"""
clicked!
clicked!

"""
import BooJs.Tests.Support

def clicked(sender, args):
	print("clicked!")

c = Clickable(Click: clicked)
c.RaiseClick()
c.RaiseClick()
