"""
1 foo
2 foo 2
other
2 foo 2
3 FOO
4 100
5
--
int-string
hash-array
other
"""

def m(data):
    match data:
        case a=string():
            print '1', a
        case array(a=string(), b=int(), *_):
            print '2', a, b
        case Hash(foo: a=string()):
            print '3', a
        case Hash(foo: c) and c is not null:
            print '4', c
        case a = Hash():
            print '5'
        otherwise:
            print 'other'

def mm(datum1, datum2):
    match datum1, datum2:
        case int(), string():
            print 'int-string'
        case Hash(foo: string()), array(int(), double()):
            print 'hash-array'
        otherwise:
            print 'other'


m('foo')
m(('foo',2,3))
m((1,2,3))
m(['foo',2,'baz'])
m({'foo': 'FOO', 'bar': 'BAR'})
m(Hash(foo: 100))
m({'bar': 'bar'})

print '--'

mm(10, 'foo')
mm({'foo':'foo'}, (10, 10))
mm(Hash(bar:'bar'), (10, 10))
