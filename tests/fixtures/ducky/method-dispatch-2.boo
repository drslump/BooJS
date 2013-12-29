#UNSUPPORTED: Runtime overloading based on argument type
#DUCKY
"""
tom
tom
crash
"""
class Drum:
	pass
	
class Cymbal:
	pass
	
class Player:
	def play(drum as Drum):
		print "tom"
	
	def play(cymbal as Cymbal):
		print "crash"
	
p = Player()
for item as object in [Drum(), Drum(), Cymbal()]:
	p.play(item)
