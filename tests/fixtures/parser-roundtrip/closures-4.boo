"""
clicked!
yes, it was!
[object Object] clicked!
"""
from BooJs.Tests.Support import Clickable

button = Clickable()
button.Click += def:
	print("clicked!")
if button:
	button.Click += def ():
		print("yes, it was!")
	if 3 > 2:
		button.Click += def (sender):
			print("${sender} clicked!")

	button.RaiseClick()
