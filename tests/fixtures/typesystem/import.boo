"""
Male: 0
Female: 1
"""

class Foo:
    static def sfoo():
        print 'Foo:sfoo'

    virtual def foo():
        print 'Foo:foo'

class Bar(Foo):
    static def sfoo():
        print 'Bar:sfoo'
    static def sbar():
        print 'Bar:sbar'

    public field = 'field'

    def constructor():
        print 'bar'

    def constructor(s as string):
        self()
        print 'bar', s

    override def foo():
        super()
        print 'Bar:foo'
    def bar():
        print 'Bar:bar'
    def bar(x as int):
        self.bar()

bar = Bar('foo', field:'f')
print bar.field
bar.foo()

/*
import BooJs.Tests.Support as AliasNamespace
import BooJs.Tests.Support(Gender, Card, method)
import BooJs.Tests.Support.Gender as AliasType
import BooJs.Tests.Support(Gender, Card) as AliasGroup
# The following is not supported by Boo :(
#import BooJs.Tests.Support(Gender as G, Card as C)
#import BooJs.Tests.Support(Gender as G, Card as C) AliasAliases


print 'Male:', Gender.Male
print 'Female:', Gender.Female

assert method(Gender.Female) == AliasNamespace.Gender.Female
assert method(Gender.Female) == AliasType.Female
assert method(Gender.Female) == AliasGroup.Gender.Female
assert method(Card.diamonds) == AliasGroup.Card.diamonds
#assert v(Gender.Female) == G.Female
#assert v(Card.diamonds) == AliasAliases.C
*/