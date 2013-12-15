"""
before
clicked!
after
"""
import BooJs.Tests.Support


def click(sender):
	print("clicked!")

c = Clickable()
c.Click += click  #System.EventHandler(null, __addressof__(click))

print("before")
c.RaiseClick()
print("after")
