a_int as int = 2
a_uint as uint = 2
a_double as double = 2.5
d_int as duck = a_int
d_uint as duck = a_uint
d_double as duck = a_double

assert d_int + a_int == a_int + a_int
assert d_int + a_uint == a_int + a_uint
assert d_int + a_double == a_int + a_double

assert d_uint - a_int == a_uint - a_int
assert d_uint * a_double == a_uint * a_double

assert d_double + a_int == a_double + a_int
assert d_double / a_int == a_double / a_int

assert -d_double == -a_double

