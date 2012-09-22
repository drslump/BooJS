a = (cast(int, 0), cast(int, 1))

#assert Type.GetType("System.Byte[]") is a.GetType()
assert 0 == a[0]
assert 1 == a[1]
