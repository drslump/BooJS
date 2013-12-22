#IGNORE: Getters not supported yet
"""
"""

from BooJs.Tests.Support import Clickable

class App:
	
	[getter(Times)]
	_times = 0
	
	def Run():
		button = Clickable()
		button.Click += { ++_times }
			
		button.RaiseClick()
		button.RaiseClick()

app = App()
app.Run()
assert 2 == app.Times
