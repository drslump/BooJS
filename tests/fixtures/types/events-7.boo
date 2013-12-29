#IGNORE: BUG - Static events
"""
Idle called
"""

class Application:
	
	static event Idle as callable(object, object)
	
	static def Run(o):
		Idle(null, null)
	
class Test:
	
	_idleHandler as callable(object, object) = Application_Idle
	
	def constructor():
		Application.Idle += _idleHandler
		
	def Application_Idle():
		Application.Idle -= _idleHandler
		print "Idle called"

t = Test()
Application.Run(t)
Application.Run(t)
