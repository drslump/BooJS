"""
int True
int-double False
uint True
uint-negative False
double True
double-int True
bool True
string True
string-int False
callable True
callable-null False
Array True
Hash-literal True
Hash-array False
Hash-Hash True
Hash-Type True
Number-int True
Number-double True
Date True
Date-int False
"""

a_int as object = -10
a_uint as object = 10
a_double as object = 10.5
a_bool as object = true
a_string = 'foo'
a_callable = {x| print x}
a_hash = {}
a_date = Date()

print 'int', a_int isa int
print 'int-double', a_double isa int
print 'uint', a_uint isa uint
print 'uint-negative', a_int isa uint
print 'double', a_double isa double
print 'double-int', a_int isa double
print 'bool', a_bool isa bool
print 'string', a_string isa string
print 'string-int', a_int isa string
print 'callable', a_callable isa callable
print 'callable-null', null isa callable
print 'Array', [1, 2] isa Array
print 'Hash-literal', a_hash isa Hash
print 'Hash-array', (1, 2) isa Hash
print 'Hash-Hash', Hash(a:10) isa Hash
print 'Hash-Type', a_date isa Hash
print 'Number-int', a_int isa Number
print 'Number-double', a_double isa Number
print 'Date', a_date isa Date
print 'Date-int', a_int isa Date
