#IGNORE: Not compatible with Jurassic engine
"""
0
>1
>3
>5
>7
>9
2
>3
>5
>7
>9
4
>5
>7
>9
6
>7
>9
8
>9
"""

max = 10
for i in range(max):
	continue if i % 2
	print i
	for j in range(i, max):
		continue unless j % 2
		print ">$j"
