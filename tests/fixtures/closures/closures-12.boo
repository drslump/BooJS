"""
@IGNORE@ Classes not supported
before
clicked!!!
after
"""
import BooCompiler.Tests.SupportingClasses from BooCompiler.Tests

c = Clickable(Click: { print("clicked!!!") })
print("before")
c.RaiseClick()
print("after")

