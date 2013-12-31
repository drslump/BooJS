"""
10
"""

class Foo:

    _field as int
    Prop as int:
        get: return _field
        set: _field = value

f = Foo()
f.Prop = 10

print f.Prop