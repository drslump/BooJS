"""
true
false
true
true
true
true
true
false
"""
enum Level:

	Boring
	
	Info
	
	Debug
	
	Error


print Level.Boring == Level.Boring
print Level.Boring != Level.Boring
print Level.Boring < Level.Info
print Level.Boring <= Level.Info
print Level.Info < Level.Debug
print Level.Error > Level.Info
print Level.Error >= Level.Error
print Level.Error < Level.Error

