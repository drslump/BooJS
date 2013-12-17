#NOTE: When converted to javascript `a : b` is interpreted as `"a" : "b"`
"""
bar
eggs
"""
a = {}
b = { "foo" : "bar" }
c = {
		a : b,
		"spam" : "e" + "g" + "g" + "s"
	}

print b['foo']
print c['spam']