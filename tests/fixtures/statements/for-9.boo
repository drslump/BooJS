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

for i in range(10):
	continue if i % 2
	print i
	for j in range(i, 10):
		continue if 0 == j % 2
		print ">$j"
