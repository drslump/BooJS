class User:
	public Login as string
	
	def constructor(login):
		Login = login

def find(l as Array, fn as callable):
	for itm in l:
		return itm if fn(itm)
	return null
		
l = [User("eric"), User("john"), User("guido")]
assert l[-1] is find(l, { user as User | return "guido" == user.Login })
assert l[0] is find(l, { user as User | return "eric" == user.Login })
assert l[-2] is find(l, { user as User | return "john" == user.Login })
assert find(l, { return false }) is null
assert l[0] is find(l, { return true })
