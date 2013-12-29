#IGNORE: BUG - regex =~ operator
"""
"Bambo"

"""
s = "\"Bamboo\"\n"
re = /foo\(bar\)/

if s =~ re:
	print s
