#IGNORE: BUG - Initialize enum values
"""
0
"""
class Foo:		
	public static Level as LogLevel

enum LogLevel:
	None
	Info
	Error
	
print(Foo.Level)
		
