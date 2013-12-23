"""
VarArgs.Method(1, 2)
VarArgs.Method([object Object])
VarArgs.Method
"""
from BooJs.Tests.Support import VarArgs

d = VarArgs()
d.Method(1, 2)
d.Method((Object(),))
d.Method()
