"""
Male: 0
Female: 1
"""

import BooJs.Tests.Support as AliasNamespace
import BooJs.Tests.Support(Gender, Card)
import BooJs.Tests.Support.Gender as AliasType
import BooJs.Tests.Support(Gender, Card) as AliasGroup
# The following is not supported by Boo :(
#import BooJs.Tests.Support(Gender as G, Card as C)
#import BooJs.Tests.Support(Gender as G, Card as C) AliasAliases

# Use this function to avoid automatic constant folding
def v(value) as int:
	return value

print 'Male:', Gender.Male
print 'Female:', Gender.Female

assert v(Gender.Female) == AliasNamespace.Gender.Female
assert v(Gender.Female) == AliasType.Female
assert v(Gender.Female) == AliasGroup.Gender.Female
assert v(Card.diamonds) == AliasGroup.Card.diamonds
#assert v(Gender.Female) == G.Female
#assert v(Card.diamonds) == AliasAliases.C
