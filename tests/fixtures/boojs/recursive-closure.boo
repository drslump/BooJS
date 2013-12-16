#IGNORE: BUG with recursing closures
"""
3
2
1
0
"""
def runit(x as int):
	def closure():
		print x
		if x--:
			closure() if x > 0

	closure()

runit(3)