"""
9 bottles of beer on the wall,
             9 bottles of beer
             Take one down, pass it around
             8 bottles of beer on the wall
8 bottles of beer on the wall,
             8 bottles of beer
             Take one down, pass it around
             7 bottles of beer on the wall
7 bottles of beer on the wall,
             7 bottles of beer
             Take one down, pass it around
             6 bottles of beer on the wall
6 bottles of beer on the wall,
             6 bottles of beer
             Take one down, pass it around
             5 bottles of beer on the wall
5 bottles of beer on the wall,
             5 bottles of beer
             Take one down, pass it around
             4 bottles of beer on the wall
4 bottles of beer on the wall,
             4 bottles of beer
             Take one down, pass it around
             3 bottles of beer on the wall
3 bottles of beer on the wall,
             3 bottles of beer
             Take one down, pass it around
             2 bottles of beer on the wall
2 bottles of beer on the wall,
             2 bottles of beer
             Take one down, pass it around
             1 bottle of beer on the wall
1 bottle of beer on the wall,
             1 bottle of beer
             Take one down, pass it around
             No more bottles of beer on the wall
"""

def bottles(n):
    bottle = ('bottle' if n == 1 else 'bottles')
    return '{0} {1}' % ((n if n else 'No more'), bottle)
 
# Start counting at 9 to save some space :)
for i in range(9, 0, -1):
    print """{0} of beer on the wall,
             {1} of beer
             Take one down, pass it around
             {2} of beer on the wall""" % ( bottles(i), bottles(i), bottles(i-1) )

