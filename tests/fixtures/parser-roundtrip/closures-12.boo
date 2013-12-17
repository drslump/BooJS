"""
"""
a = [1, 2, 3].filter do (item as int):
	return item > 2
if len(a) != 1:
	raise "OUCH!"

