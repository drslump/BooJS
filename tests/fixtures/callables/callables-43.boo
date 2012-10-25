
	
a = { item | return item.toString() }, { item as string | return item.toUpperCase() }

assert "3" == a[0](3)
assert "FOO" == a[-1]("foo")
