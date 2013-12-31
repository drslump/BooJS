"""
007
"""

public class Class:
	[property(Closure)]
	field as callable(int) as string = { i | '00' + i }

print Class().Closure(7)
