#IGNORE: Events not supported yet
"""
before
clicked!
after
"""
import BooJs.Tests.Support

def click():
	print("clicked!")

c = Clickable(Click: click)
print("before")
c.RaiseClick()
print("after")
