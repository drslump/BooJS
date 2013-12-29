#IGNORE: Properties not supported yet

class Action:
	cb = null
	def constructor(callback):
		cb = callback

class A:
	[property(Go)]
	action = Action() def():
		print("Hello World")
