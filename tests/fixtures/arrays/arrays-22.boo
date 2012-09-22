#IGNORE: Not sure what this should do. Since the values are casted to simple objects
#        the special Array.op_Equality method is not called, thus we can just compare
#        the instances, which in Javascript case are different since lists are implemented
#        using mutable arrays.
"""
"""
a1 as object = (1, 2)
a2 as object = (1, 2)
assert a1 == a2

a3 as object = ((1, 2), (3, 4))
a4 as object = ((1, 2), (3, 4))
assert a3 == a4

