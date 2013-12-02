"""
invocation
multiline
multiline declared
3.14159265358979
0
1
2
"""

`console.log('invocation')`
`var a = 'multiline';
 console.log(a);
`
# Check the variable was properly declared
global a
print a, 'declared'

v = `Math.PI`
print v

for i in range(`Math.max(1, 3)`):
	print i
