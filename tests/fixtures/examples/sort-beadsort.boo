#TODO: Not fully ported
"""
7, 5, 4, 3, 1, 1, 1
"""
def zip_longest(*args as (list)):
	return map(None, args)
 
def beadsort(l as list):
	return map(columns(columns( ([1] * e for e in l) )))
 
def columns(l as list):
  	return [filter(None, x) for x in zip_longest(*l)]
 
l = beadsort([5,3,1,7,4,1,1])
print join(l, ', ')

