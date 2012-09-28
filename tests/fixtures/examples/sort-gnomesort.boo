"""
1, 2, 3, 4, 5, 6
"""
def gnome_sort(lst as (int)):
    i, j, size = 1, 2, len(lst)
    while i < size:
        if lst[i-1] <= lst[i]:
            # TODO: This cast shouldn't be necessary
            i, j = j, cast(int, j+1)
        else:
            t = lst[i]
            lst[i] = lst[i-1]
            lst[i-1] = t
            i -= 1
            if i == 0:
                # TODO: This cast shouldn't be necessary
                i, j = j, cast(int, j+1)
 
lst = [3,4,2,5,1,6]
gnome_sort(lst)
print join(lst, ', ')
