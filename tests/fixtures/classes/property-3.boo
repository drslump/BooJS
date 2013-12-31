"""
10
"""

class Foo:

    [property(Prop)]
    _field as int


f = Foo()
f.Prop = 10

print f.Prop