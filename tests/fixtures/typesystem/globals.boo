"""
foo
20
myobj is not defined
myint is not defined
"""
# console is defined in the test runner
global console as duck
console.log('foo')
console.prop = 10
console.prop += 10
print console.prop

global myobj
try: 
	myobj.foo()
except: 
	print 'myobj is not defined'

try: 
	global myint as int = 10
except: 
	print "myint is not defined"


