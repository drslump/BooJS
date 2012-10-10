"""
0, 1, 2
0, 1, 3
0, 1, 4
0, 2, 3
0, 2, 4
0, 3, 4
1, 2, 3
1, 2, 4
1, 3, 4
2, 3, 4
"""

def comb(m as int, lst as (int)) as ((int)):
    return [[]] if not m
    return [] if not len(lst)
    return ( lst.slice(0,1) + a for a in comb(m-1, lst.slice(1)) ) + comb(m, lst.slice(1))

for l in comb(3, range(5)):
    print join(l, ', ')