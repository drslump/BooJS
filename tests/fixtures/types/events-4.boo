#UNSUPPORTED: .Invoke is not supported
"""
before
no handlers
after
before
got it!
after
"""

class Observable:

	event Changed as callable(object, object)
	
	def RaiseChanged():
		print("before")
		if Changed is null:
			print("no handlers")
		else:
			# the event reference can be treated
			# as a delegate
			Changed.Invoke(self, EventArgs.Empty)
		print("after")
			
			
o = Observable()
o.RaiseChanged()
o.Changed += { print("got it!") }
o.RaiseChanged()
