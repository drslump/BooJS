#IGNORE: Array initializer not supported yet
"""
foo
foo,bar
"""
h1 = Array[of string]() { "foo" }
h2 = Array[of string]() { "foo", "bar" }

print h1
print h2
