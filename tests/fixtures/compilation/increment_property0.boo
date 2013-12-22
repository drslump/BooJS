#IGNORE: Increment on non simple references should raise a not supported error
"""
4
"""
class Integer:
	_value as int
	
	def constructor(value as int):
		_value = value
	
	Value:
		get:
			return _value
		set:
			_value = value

	override def toString():
		return _value.toString()

i = Integer(3)
++i.Value
print(i)
