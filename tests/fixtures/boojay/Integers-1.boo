#!IGNORE: Classes not supported yet
"""
-42
-1
0
42
128
255
256
32767
-32768
2147483647
-2147483648
2130903040
True
False
True
42
"""

class I:
	public value as int

def sysout(i as int):
	print i

sysout -42
sysout -1
sysout 0
sysout 42
sysout 128
sysout 255
sysout 256
sysout 32767
sysout -32768
sysout 2147483647
sysout -2147483648
sysout 0x7f030000

print 42 == (21*2)
print 41 == (21*2)
print 41 != (21*2)
print I(value: 42).value