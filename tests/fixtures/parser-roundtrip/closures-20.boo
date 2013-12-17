"""
foo
bar
"""
c1 = { print "foo" }
c2 = { item | print item if item is not null }

c1()
c2('bar')
