"""
5.5
1
3.414171521474055
"""

def arithmetic_mean(lst as (double)) as double:
    sum as int = reduce(lst, {a as double, b as double| a+b}, 0)
    return sum / len(lst)
 
def geometic_mean(lst as double*) as double:
    product = reduce(lst, {a as double, b as double| a*b}, 1)
    return Math.pow(product, 1/len(lst))
 
def harmonic_mean(lst as double*) as double:
    sum as double = reduce(lst, 0, {a as int, b as int| a + 1 / b})
    return len(lst) / sum
 
lst = [1,2,3,4,5,6,7,8,9,10]
print arithmetic_mean(lst)
print geometic_mean(lst)
print harmonic_mean(lst)