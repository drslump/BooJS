"""
0,1,4,9,16,25,36,49,64,81
1,3,5,7,9
0,2,4,6,8
2,1,4,3
"""
print(i*i for i in range(10))
print([i for i in range(10) if i % 2])
print(i for i in range(10) unless i % 2)
print(array((j, i) for i, j in ((1, 2), (3, 4))))
