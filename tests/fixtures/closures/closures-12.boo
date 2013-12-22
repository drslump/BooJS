"""
before
clicked!!!
after
"""
from BooJs.Tests.Support import Clickable

c = Clickable(Click: { print("clicked!!!") })
print("before")
c.RaiseClick()
print("after")

