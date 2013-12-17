"""
"""
class Maybe[T]:
	pass
	
class Some[T](Maybe[T]):
	public value as T
	
class None[T](Maybe[T]):
	pass
