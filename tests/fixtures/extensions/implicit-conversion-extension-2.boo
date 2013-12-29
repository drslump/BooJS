#IGNORE: BUG - implicit conversion not supported
enum E:
	None
	Foo = 1
	Bar = 2
	Baz = 4

[Extension]
static def op_Implicit(e as Enum) as bool:
	return cast(int, e) != 0

flags = E.Foo | E.Bar

value as bool = flags & E.Foo
assert value

value = flags & E.Bar
assert value

value = flags & E.Baz
assert not value

