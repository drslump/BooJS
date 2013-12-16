"""
int: 10
str: bar baz
int: 10
str: bar baz
"""

def foo(a as int):
	print "int: $a"
def foo(b as string, c as string):
	print "str: $b $c"

foo(10)
foo('bar', 'baz')

# Test runtime overload dispatching
js `exports.foo(10)`
js `exports.foo('bar', 'baz')`

