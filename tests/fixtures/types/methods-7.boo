"""
succeeded!
failed!
"""
def test(condition as bool):
	try:
		raise "failed!" if not condition
		return "succeeded!"
	except x:
		return x.message
		
print(test(true))
print(test(false))
