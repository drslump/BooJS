def arithmetic_mean(lst as list) as double:
    sum = reduce(lst, {a,b| a+b}, 0)
    return sum / len(lst)
 
def geometic_mean(lst as list) as double:
    product = reduce(lst, {a,b| a*b}, 1)
    return Math.pow(product, 1/len(lst))
 
def harmonic_mean(lst as list) as double:
    sum as double = reduce(lst, {a as int, b as int| a+1/b}, 0)
    return len(lst) / sum
 
lst = [1,2,3,4,5,6,7,8,9,10]
print arithmetic_mean(lst)
print geometic_mean(lst)
print harmonic_mean(lst)