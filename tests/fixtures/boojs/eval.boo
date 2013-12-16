"""
invocation
multiline
multiline declared
3.14159265358979
foo
0
1
2
"""

js `console.log('invocation')`
js `var a = 'multiline';
 console.log(a);
`
# Check the variable was properly declared
global a
print a, 'declared'

v = js('Math.PI')
print v

# Uses eval if the expression is not just a literal string
js "console.log('{0}')" % ('foo',)

for i in range(js('Math.max(1, 3)')):
	print i
