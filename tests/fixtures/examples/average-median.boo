#!DUCKY
"""
4.4
"""
def median(lst as (double)):
    # create a sorted copy
    srtd as (double) = lst.slice(0).sort()  # non-ducky
    #srtd = lst.slice(0).sort()  # ducky 
    alen = len(srtd)
    return 0.5 * ( srtd[(alen-1) >> 1] + srtd[alen >> 1] )
 
a = (4.1, 5.6, 7.2, 1.7, 9.3, 4.4, 3.2)
print median(a)
