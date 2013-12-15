"""
before
clicked!
after
"""
import BooJs.Tests.Support

def click(o):
	print("clicked!")

c = Clickable(Click: click)
print("before")
c.RaiseClick()
print("after")
