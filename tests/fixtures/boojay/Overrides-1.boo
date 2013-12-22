"""
yeah
yeah
"""
class Overrides1:
	def toString():
		return "yeah"
		
o1 = Overrides1()
o2 = Overrides1()
print o1
print o2.toString()