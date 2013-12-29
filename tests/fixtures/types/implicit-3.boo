#IGNORE: BUG - Implicit overloading not fully supported
"""
Alpha(1)
Bravo(1)
Alpha(1)
Bravo(1)
"""

class Alpha:
	def constructor(value as double):
		Value = value
	
	override def toString():
		return "Alpha(${Value})"
	
	public Value as double

class Bravo:
	def constructor(value as double):
		Value = value
	
	def op_Implicit(value as Alpha) as Bravo:
		return Bravo(value.Value)
	
	def op_Implicit(value as Bravo) as Alpha:
		return Alpha(value.Value)
	
	override def toString():
		return "Bravo(${Value})"
	
	public Value as double

def PrintAlpha(alpha as Alpha):
	print alpha
	
def PrintBravo(bravo as Bravo):
	print bravo

PrintAlpha(Alpha(1))
PrintBravo(Bravo(1))
PrintAlpha(Bravo(1))
PrintBravo(Alpha(1))

