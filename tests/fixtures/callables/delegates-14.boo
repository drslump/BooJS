"""
before
clicked!
after
"""
import BooJs.Tests.Support


def click(o):
	print("clicked!")

c = Clickable()
c.Click += click

print("before")
c.RaiseClick()
print("after")
