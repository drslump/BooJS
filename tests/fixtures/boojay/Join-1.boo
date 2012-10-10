"""
foo bar
foo, bar
"""
list = Array()
list.push("foo")
list.push("bar")
print join(list)
print join(list, ", ")