"""
Hello World
"""
class Action:
	cb as callable = null
	def constructor(callback):
		cb = callback
	def run():
		cb()

class A:
	[property(Go)]
	action = Action() def():
		print("Hello World")

a = A()
a.Go.run()