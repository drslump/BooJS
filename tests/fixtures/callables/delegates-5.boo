"""
added
clicked!
removed
added
clicked!
removed
"""
import BooJs.Tests.Support

class Application:
	
	def Run():		
		c = Clickable()
		
		for i in range(2):			
			c.Click += clicked
			print("added")
		
			c.RaiseClick()
		
			c.Click -= clicked
			print("removed")
			
			c.RaiseClick()
		
	def clicked(sender):
		print("clicked!")
		
Application().Run()
