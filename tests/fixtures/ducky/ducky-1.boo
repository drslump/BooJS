#UNSUPPORTED: Ducky values do not resolve properties
#DUCKY
"""
Homer Simpson
John Cleese
"""
class Celebrity:
	_name = ''
	Name as string:
		get: return _name
		set: _name = value
	
people = [Celebrity(Name: "Homer Simpson"), Celebrity(Name: "John Cleese")]
for person in people:
	print person.Name
