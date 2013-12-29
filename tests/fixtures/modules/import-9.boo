#UNSUPPORTED: Need more test namespaces to make it work
"""
1
1
1
"""
from BooJs.Tests.Support import *
from BooJs.Tests.Support import Gender as G
from BooJs.Tests.Support import TestEnum

print Gender.Female
print G.Female
print TestEnum.Foo
