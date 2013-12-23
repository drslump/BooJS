#IGNORE: BUG - type definition order should not matter
"""
"""
class C2(C1):
	pass
	
class C1:
	pass

assert js(`exports.C2.prototype.$boo$super`) is C1
