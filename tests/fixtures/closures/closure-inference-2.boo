#IGNORE: Properties not supported yet
"""
007
"""

public class Class:
	[property(Closure)]
	field as callable(int) as string = { i | i.toString("000") }

print Class().Closure(7)
