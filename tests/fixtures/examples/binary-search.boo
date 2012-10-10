def binary_search_recursive(a as (int), value as int, lo as int, hi as int) as int:
    return -1 if hi < lo
    mid = Math.floor((lo+hi)/2)
    if a[mid] > value:
        return binary_search_recursive(a, value, lo, mid-1)
    elif a[mid] < value:
        return binary_search_recursive(a, value, mid+1, hi)
    else:
        return mid

def binary_search_iterative(a as (int), value as int):
    lo = 0
    hi = len(a.length) - 1
    while lo <= hi:
        mid = Math.floor((lo+hi)/2)
        if a[mid] > value: hi = mid - 1
        elif a[mid] < value: lo = mid + 1
        else: return mid
    return null

items = (1,3,5,10,100,3000,3001,5000)

print 'recursive', binary_search_recursive(items, 100, 0, len(items))
print 'iterative', binary_search_iterative(items, 100)