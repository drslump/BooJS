"""
1, 3, 4, 8, 10
"""

def bubble_sort(seq as (int)):
    changed = true
    while changed:
        changed = false
        for i in range(len(seq) - 1):
            if seq[i] > seq[i+1]:
                t = seq[i]
                seq[i] = seq[i+1]
                seq[i+1] = t
                changed = true

lst = (10, 3, 4, 8, 1)
bubble_sort(lst)
print join(lst, ', ')
