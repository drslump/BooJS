#UNSUPPORTED: char type not supported
"""
"""
def chr(value):
	return cast(System.IConvertible, value).ToChar(null)
	
assert chr(65535) == System.Char.MaxValue
assert chr(0) == System.Char.MinValue
