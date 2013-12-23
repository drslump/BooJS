#IGNORE: BUG - Initialize enum values
"""
0
"""
enum LogLevel:
	None
	Info
	Error

class Foo:		
	public static Level as LogLevel
	
print(Foo.Level)
		
