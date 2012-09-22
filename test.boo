/*
namespace DrSlump

import System

class Foo:
  bar as int
*/

a = 10

/*

MYFO = 10

print MYFO

def foo():
    for i in {'a':1,'b':2}:
        for i in (1,2,3,4):
            for i in (1,2,3):
                print i

    for i in range(10, 0):
        print i

#a = 10
#print "Hello $a == $a!"
*/
/*
def foo():
    yield 1
for i in foo():
  print i

for i in [0,1,2]:
    print i
*/
/*
for i in "hello":
    print i

for i in global.foo:
    print i

d = range(10)
for i in d:
    print i

for i in [1, 2, 3, 4]:
    print i


for i in {'a':1,'b':2}:
    print i
*/
/*
def power(base as int, exponent as int):
  result = 1
  for count in range(0, exponent):
    result *= base
  return result

print power(2, 10)
*/

/*
# Swap values without a temporary variable:
a = 4
b = 5
c = 6
print a, b, c

a, b, c = b, c, a
print a, b, c
*/

/*
def getbottle(n as int):
    return "no more bottles of beer" if n==0
    return "1 bottle of beer" if n==1
    return "$n bottles of beer"
 
b = getbottle(n = 5)
while true:
    print "$b on the wall, $b,"
    if n > 0:
        print "take one down, pass it around,"
    else:
        print "go to the store, buy some more,"
        n = 100
    b = getbottle(--n)
    print "$b on the wall."
*/

    #ltuae = (42 if true else null)

/*
    :lab1
    a++
    if a < 10: goto lab1
*/

/*
    jQ = global.jQ
    jQ('div') do:
        pass

    @'foo' .
    @'div'

    # $("div.contentToChange p").size()
    jQ("div.contentToChange p").size()

    # $("div.contentToChange p.firstparagraph:hidden").slideDown("slow");
    # $("div.contentToChange p.firstparagraph:visible").slideUp("slow");
    jQ('div.contentToChange p.firstparagraph:hidde').slideDown('slow')
    jQ('div.contentToChange p.firstparagraph:visible').slideUp('slow')

    // $(document).ready(function() { ... }    
    jQ(global.document).ready({x| true })

    // $("#orderedlist").find("li").each(function(i) {
    //   $(this).append( " BAM! " + i );
    // });
    jQ('#orderedlist').find('li').each({i|
        jQ(global.this).append(' Bam! ')
    })
*/






        

/*
    a = 10_000
    print a, '10', false, foo

    global.global.foo = 1

    #fn = {x| 'hello' }

    if a < 10:
        pass
    elif a > 10: pass
    else: pass 

    b = 0.112312312312



    for i in range(10):
        print i
    or:
        pass

    while false:
        pass
    or:
        pass
    then:
        pass
*/
/*
for (i=0; i<10; i++) {
  continue
  pass
}

# Start counter at START-1 since we increment first in loop
i=-1
while (i<10) {
  i++;
  continue;
  pass
}

# List/Hash iteration
for v in obj:
  pass

# We might need to use runtime when the type is not known
for (k in obj) {
  v = obj[k];
}

# array
l=obj.length;
while(i++ < l){
  v = obj[i]
}

# hash
keys = [];
for (k in obj) keys.push(k);
i = 0;
while (i<keys.length) {
  v = obj[keys[i]]
  pass
  i++
}

# duck
Boo.each(obj, {v| pass })


# Generators
while ( (itm = obj.next()) !== STOP ) {
  pass
}

# Change Boo's behaviour
for k, v in hash:
  pass

# hash
keys = [];
for (k in obj) keys.push(k);
i = 0;
while (i<keys.length) {
  k = keys[i];
  v = obj[k];
  pass
  i++
}

# duck
Boo.each(obj, {v,k|pass})

# Use macro for hasOwnProperty
forown k, v in hash:
  pass

for k, v in hash:
  if hash.hasOwnProperty(k):
    pass

# If only one param use a temp variable
forown v in hash:
  pass

forown _k, v in hash:
  pass

*/



/*
def foo():
    a = 'foo' if true
    while (true):
        while (false):
            pass
    a = "After loops"
    yield 1 

    a = 'bar'
    yield 2
*/
/*
for i in range(10):
    print i
or:
    print 'Not loop'
then: 
    print 'After Loop'
*/
/*
$looped = false;
for(i in range(10)) {
  $looped = true;
  
}
if (!$looped) { // or
    print 'Not loop'
} else { // then
    print 'After loop
}
*/

/*
## Example of a mixing attribute macro
struct Mix: # We can have a simple 'mixin' macro that converts to a struct
    pass

# Incorporate as an instance in self._mix
class Bar:
    [mixin] _mix as Mix

# Merge the contents of the mixin into the class
[mixin(Mix)] class Bar:
    pass

*/

/*

class Foo:
    field as int
    static bar = 10

    def constructor():
        field = 1

    static def op_Addition(x as Foo, y as int):
        return x

    static def op_Addition(x as Foo, y as Foo):
        return x

    static def op_Addition(x as Foo, y as object):
        return x

a = @/foo bar/

if true:
    f = Foo()
    b as duck = 10
    c = f + b
*/
/*
enum Status:
    Active
    Pending
    Blocked


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
