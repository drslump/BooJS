"""
boo!
0
boo!
1
2
boo!
2
1
"""
def hasSideEffect(index):
	print "boo!"
	return index
	
i = (0.0,)
# NOTE: originally idx variable wasn't used but the JS engine used in the test
# harness does not support it.idx = hasSideEffect(0)
idx = hasSideEffect(0)
print i[idx]++
idx = hasSideEffect(0)
print i[idx]++
print i[0]
idx = hasSideEffect(0)
print i[idx]--
print i[0]
