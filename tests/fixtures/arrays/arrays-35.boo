#IGNORE: matrix method not supported
"""
1
2
3
4
5
6
7
8
"""

a = matrix(int, 5, 2, 4)

a[0,0,0]=1
a[0,0,1]=2
a[0,0,2]=3
a[0,0,3]=4
a[0,1,0]=5
a[0,1,1]=6
a[0,1,2]=7
a[0,1,3]=8

b=a[0:1,0:2,0:4]

for i in b:
	print(i)
