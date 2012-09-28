#IGNORE: BooJs doesn't allow return statements inside for in loops
"""
0, 1, 2, 3, 4, 5, 6, 7, 8, 9
"""

def cocktailSort(lst as (int)):
    up = range(len(lst)-1)
    swapped = true
    while swapped:
        for indices in (up, reversed(up)):
            swapped = false
            for i in indices:
                if lst[i] > lst[i+1]:  
                    t = lst[i]
                    lst[i] = lst[i+1]
                    lst[i+1] = t
                    swapped = true
            if not swapped:
                return 

lst = [7, 6, 5, 9, 8, 4, 3, 1, 2, 0]
cocktail_sort(lst)
print join(lst, ', ')
