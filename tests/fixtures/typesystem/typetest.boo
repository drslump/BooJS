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
Hash False
Number-int True
Number-double True
ReturnValue True
ReturnValue-int False
"""

a_int as object = -10
a_uint as object = 10
a_double as object = 10.5
a_bool as object = true
a_string = 'foo'
a_callable = {x| print x}
a_hash = {}
a_return = ReturnValue(true)

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
print 'Hash', a_hash isa Hash
print 'Number-int', a_int isa Number
print 'Number-double', a_double isa Number
print 'ReturnValue', a_return isa ReturnValue
print 'ReturnValue-int', a_int isa ReturnValue
