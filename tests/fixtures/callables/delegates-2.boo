"""
clicked!
clicked!
"""
import BooJs.Tests.Support


def clicked(sender):
	print("clicked!")

c = Clickable()
c.Click += clicked
c.RaiseClick()
c.RaiseClick()
