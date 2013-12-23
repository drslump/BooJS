"""
1 - clicked!
2 - clicked!
"""
import BooJs.Tests.Support

class Handler:
	
	public State = null
		
	def clicked(sender):
		print("${State} - clicked!")

handler = Handler(State: 1)

c = Clickable()
c.Click += handler.clicked
c.RaiseClick()
c.Click -= handler.clicked

handler.State = 2
c.Click += handler.clicked
c.RaiseClick()
