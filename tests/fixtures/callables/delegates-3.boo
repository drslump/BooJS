#IGNORE: Events not supported yet
"""
handler - clicked!
handler - clicked!

"""
import BooJs.Tests.Support

class Handler:
	
	tag = null
	
	def constructor(tag):
		self.tag = tag
		
	def clicked(sender, args):
		print("${tag} - clicked!")

c = Clickable()
c.Click += Handler("handler").clicked
c.RaiseClick()
c.RaiseClick()
