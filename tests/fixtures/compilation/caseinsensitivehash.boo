#IGNORE: Hash caseinsensitive variant is not implemented
"""
bar
True
"""
h = Hash(true)
h["foo"] = "bar"
print h["fOO"]
print "FOO" in h
