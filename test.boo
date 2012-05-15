def foo(msg):
  b = msg
  print b
  return true unless b
  return false


a = (10 if true else 20)

if a == 'foo':
    b = false
    foo("TEST = $a")
elif not true:
    print 'elif'
else:
    print char('C')

if 'foobar' =~ 'foo':
    pass

unless b:
    print 'unless'




#h = { 'foo': 1, 'bar': 1 }
h = ( 3, 5, 6 )
for v,k in h:
    print 'Value: ', v, ' Key', k


#console = global('console')
#console = require('console')
#require console
#global console 
console as global  # Define `global` type inheriting from duck. Do not generate `var console`
console.log.info('foo')

# TODO: Modify parser to allow ? at the end of idents?
# console?.log('foo')
