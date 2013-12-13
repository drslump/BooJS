#IGNORE: Events not supported yet
"""
before
clicked!
after
"""
import BooJs.Tests.Support


def click(sender, args):
	print("clicked!")

c = Clickable(Click: System.EventHandler(null, __addressof__(click)))

print("before")
c.RaiseClick()
print("after")
