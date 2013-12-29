#!IGNORE: Type system not fully supported
"""
1, bar
2, baz
3, foo
1
2
3
4
5
8
null
null
1, 1
1, 2
1, 2, 3
1, 2, 4
1, 3
null
"""
def sort(items as Array):
	for item in items.sort():
		if item is null:
			print("null")
			continue
			
		if item isa Array:
			print(join(item, ", "))
			continue
		
		print(item)

sort([(3, "foo"), (1, "bar"), (2, "baz")])
sort([4, 5, 8, null, 3, 2, null, 1])
sort([(1, 2, 3), null, (1, 2, 4), (1, 3), (1, 1), (1, 2)])
	
