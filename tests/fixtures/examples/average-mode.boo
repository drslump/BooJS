"""
6
4,1
"""
def mode(lst as Array) as Array:
    counter = {}
    modes = []
    max = 0

    for v in lst:
        counter[v] = (counter[v] or 0) + 1
        cur as int = counter[v]
        if cur == max:
            modes.push(v)
        elif cur > max:
            max = cur
            modes = [v]

    return modes
 
print mode([1, 3, 6, 6, 6, 6, 7, 7, 12, 12, 17])
print mode([1, 2, 4, 4, 1])