#UNSUPPORTED: matrix method not supported
"""
1
0
2
0
3
0
0
0
0
0
0
0
0
0
0
0
"""

t1 = matrix(int, 2, 4, 2)
t2 = matrix(int, 1, 3)

t1[0,0,0]=5
t1[0,1,0]=5
t1[0,2,0]=5

t2[0,0]=1
t2[0,1]=2
t2[0,2]=3

t1[0:1,0:3,0]=t2

for i in t1:
	print(i)
