"""
1,2,3 1,2,3 1,2,3  
1,2,3 1,2,3
1,2,3 1,2,3
False False
"""
/*
An extraneous trailing comma is allowed for array literals.
It makes it easier for when you comment out parts of code.
*/

a1 = (of int: 1,2,3)
a2 = (of int: 1,2,3,)
a3 = (of int:
	1,
	2,
	3,
	)
a4 = (of int:,)
//a5 = (of int:) //not supported
a6 = (,)
print a1, a2, a3, a4, a6

b1 = (1,2,3)
b2 = (1,2,3,)
print b1, b2

c1 = [1,2,3]
c2 = [1,2,3,]
print c1, c2


d1 = {1:true,
	2:false,
	3:true}
d2 = {1:true,
	2:false,
	3:true,
	#4:false
	}
print d1[2], d2[2]
