#IGNORE: BUG - IEnumerable handling is not fully supported yet
"""
foo
bar
foo
bar
foo
bar
"""
def foo() as string*:
	return ['foo', 'bar']
def bar() as string**:
	return [['foo','bar'],['foo','bar']]

for i in foo():
	print i

for l in bar():
	for i in l:
		print i
