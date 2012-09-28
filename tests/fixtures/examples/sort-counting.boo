"""
1, 2, 3, 3, 7, 7, 9, 9, 10, 10
"""
def counting_sort(lst as (int), mn as int, mx as int) as (int): 
	count = {}
	for i in lst:
		count[i] = (count[i] or 0) + 1
	result = []
	for j in range(mn, mx+1):
		result += [j] * count[j]
	return result
 
data = [9, 7, 10, 2, 10, 9, 7, 3, 3, 1]
data = counting_sort(data, 1, 10)
print join(data, ', ')
