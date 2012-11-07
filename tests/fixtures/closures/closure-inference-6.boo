"""
01 02 03 04
"""

callable Transform[of TIn, TOut](x as TIn) as TOut

def Map[of TIn, TOut](source as (TIn), func as Transform[of TIn, TOut]):
	arr = array(TOut, len(source))
	for i in range(len(source)):
		arr[i] = func(source[i])
	return arr

ints = (1,2,3,4)
strings = Map(ints, {i | i.toString()})

print join(strings)
