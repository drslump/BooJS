"""
10
nullified
10
30
10
nullified
nullified
"""

def ret(v):
	return v
def retret():
    return ret

print ret(10)?.toString()
print ret(null)?.toString() or "nullified"
print retret()?(10)?.toString()

a = (10, 20, 30)
print a.pop?()
print a?[0]
b as (int) = null
print b?.pop() or 'nullified'
print b?[0] or 'nullified'

#foo = {'bar': 'bar'}
#print foo?['bar'].toUpperCase()
#print foo['not']?.toUpperCase() or 'nullified'
	
