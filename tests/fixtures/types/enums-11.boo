#BCE0011: Constructor overloading not supported yet
"""
Release
Info
"""
class Foo:
	
	enum LogLevel:
		None
		Info
		Error

	public static Level = Bar.LogLevel.Release
	
class Bar:

	enum LogLevel:	
		Release
		Debug
		
	public static Level = Foo.LogLevel.Info

print(Foo.Level)
print(Bar.Level)
		
