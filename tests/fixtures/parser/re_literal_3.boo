#IGNORE: BUG - regex =~ operator
"""
match
"""
re = @/\x2f\u002f/
s = "${/\x2f\u002f/}"

if s =~ re:
	print "match"
