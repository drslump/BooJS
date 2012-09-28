"""
1, 2, 3, 4, 9, 12
"""
def shuffle(v as (int)):
    i = len(v)
    while i--:
        r = Math.floor(Math.random() * i)
        x = v[i]
        v[i] = v[r]
        v[r] = x
 
def sorted(v as (int)) as bool:
    # TODO: This is broken, BooJs doesn't support returns inside for loops currently
    #for i in range(1, len(v)):
    #    return false if v[i-1] > v[i]
    i = 1
    while i < len(v):
        return false if v[i-1] > v[i]
        i++

    return true
 
def bogosort(v as (int)):
    while not sorted(v):
        shuffle(v)

v = (4,1,9,3,12,2)
bogosort(v)
print join(v, ', ')