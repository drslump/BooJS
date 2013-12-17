"""
clicked!
yes, it was!
[object Object] clicked!
"""
from BooJs.Tests.Support import Clickable

button = Clickable()
button.Click += def:
	print("clicked!")

button.Click += def ():
	print("yes, it was!")
	
button.Click += def (sender):
	print("$sender clicked!")

button.RaiseClick()