"""
-1
-1
-1
-170
9.22337203685478E+18
"""

print -1.0
print -1
#print -1h  # Timespan expressions not supported
print - 1.0
print -0xAA

//x = 2147483648 //error, value one too big for an int:
xlong = 9223372036854775807L //ok, max value allowed for long (NOTE: Javascript precission exceeded)
print xlong

