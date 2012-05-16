import Boo.Lang as BL

class Foo:
    field as int
    static bar = 10

    def constructor():
        field = 1

/*
enum Status:
    Active
    Pending
    Blocked
*/

/*
def foo(msg):

  #def bar(msg):
  #  bb = msg
  bar = {msg| bb = msg}
  bar('foo')

  boo as duck = 'foo'
  boo.type(1)

  baz = boo.type

  bar({x| 
    bar(x) if true;
    boo = 1
  })
*/

/*
  #print def(x):
  #  print bar

  b = msg
  print b
  return true unless b
  return false


a = (10 if true else 20)

if a == 'foo':
    b = false
    foo("TEST -> $a")
elif not true:
    print 'elif'
else:
    print char('C')

if 'foobar' !~ 'foo':
    pass

unless b:
    print 'unless'


#h = { 'foo': 1, 'bar': 1 }
h = ( 3, 5, 6 ** a )
for k,v in h:
    print 'Value: ', v, ' Key', k

for i in range(10):
    print i

if 3 in h:
    pass
if 3 not in h:
    pass


#console = global('console')
#console = require('console')
#require console
#global console 
console as global  # Define `global` type inheriting from duck. Do not generate `var console`
console.log.info('foo')

# TODO: Modify parser to allow ? at the end of idents?
# console?.log('foo')

# Use aliased import
BL.Hash()
*/
