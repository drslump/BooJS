#UNSUPPORTED: Generics not supported yet
"""
01 02 03 04
"""

callable Transform[of TIn, TOut](x as TIn) as TOut

[Extension]
def Map[of TIn, TOut](source as (TIn), func as Transform[of TIn, TOut]):
	arr = array(TOut, source.Length)
	for i in range(source.Length):
		arr[i] = func(source[i])
	return arr

ints = (1,2,3,4)
strings = ints.Map do(i): 
	return i.ToString("00")

print join(strings)
