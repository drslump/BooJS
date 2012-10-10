"""
FOO
exception
"""
#import java.lang

o as object = "foo"
s = cast(string, o)
print s.toUpperCase()
try:
	print cast(Array, o)
except x:
	print "exception"
