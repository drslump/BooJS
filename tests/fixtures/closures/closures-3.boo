"""
before
clicked!!!
after
"""
from BooJs.Tests.Support import Clickable

c = Clickable()
c.Click += def:
	print("clicked!!!")

print("before")
c.RaiseClick()
print("after")

