#IGNORE imports not supported yet
"""
before
clicked!!!
after
"""
from BooJs.Tests.Support import Clickable

click = def:
	print("clicked!!!")

c = Clickable(Click: click)
print("before")
c.RaiseClick()
print("after")

