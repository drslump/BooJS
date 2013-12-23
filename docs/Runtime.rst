Runtime library
===============

BooJs requires a small runtime library to support the execution of the compiled
code. This library is located in the ``Boo.js`` file with an approximate size of
4Kb when minified.


Reasoning for using a runtime
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Among the Javascript community there is the idea that requiring a companion runtime 
library in order to run the generated code is a bad decision. The major complain is
that it imposes an additional dependency to keep track of, also increasing the final
code size of the delivered code, when for a *Hello World* style program you must 
include a few extra kilobytes of functions that will probably never be used.

Obviously it would be ideal to avoid the use of a runtime library, unfortunately
it's not possible to do. In order to keep code compatible with the original semantics 
from Boo, some helper functions must be available, specially since Boo does not have 
a 100% static type system.

Given the fact that a runtime is actually needed, it could be reduced to include 
just the minimum functions necessary, however there is some stuff that is much
easier to implement with a small runtime function than it would be to statically 
generate code for from the compiler. So the approach BooJs follows is to try to 
keep the runtime library small but not at the expense of complicating the compiler 
excessively.

The complaint about having an additional dependency is easily resolved by including
the runtime code inside the compiled file. It's very easy to do for Javascript and 
can be automated with any of the several build tools available.
For the one regarding the increased code size, let's just say that if the compiler
had to generate code to support the language semantics, the final size of all that 
feature specific code will probably exceed the size of the runtime for medium 
sized projects. It makes no sense to measure the overhead of a runtime using a 
simple example application, for developments so simple and small it probably doesn't 
make sense to use anything other than vanilla javascript for them.

Many compilers to Javascript will actually output their runtime support functions
as part of the generated code, so even if they can be advertised as runtime-free,
it's actually being included automatically by the compiler when generating code 
needing it. That's one approach that BooJs will probably use in the future, acting 
like a *linker* to just include those helpers actually needed for a compilation 
unit, although even then it will still have a separated runtime library with stuff 
that is very commonly used.


Builtins
~~~~~~~~

Most of the standard Boo builtins are supported in BooJs. When referencing them from
Boo code they are global symbols, if you need to reference them from JavaScript code
they are available in the ``Boo`` object (eg: ``Boo.range``). 



__RUNTIME_VERSION__
-------------------

Stores the version of the runtime currently in use. You can use this value to
work around versioning issues in your code to make it compatible with different
BooJs releases.

.. note:: To obtain the version of the compiler used to generate the code you can
          use the ``__COMPILER_VERSION__`` reference. The compiler will automatically
          convert those references to a string containing the compiler version.


Array
-----

While arrays are directly mapped to JavaScript the compiler will offer some additional
functionality when working with them: equality, addition, multiplication and membership
test.

::

    l = ['foo', 'bar', 'baz']
    if l == ('foo', 'bar', 'baz'):
        print "all items are equal"

    r = l + (10, 20)
    # result: ['foo', 'bar', 'baz', 10, 20]

    r = l * 2
    # result: ['foo', 'bar', 'baz', 'foo', 'bar', 'baz']

    if 'bar' in l:
        print "array contains 'bar'"



array
-----

Create an array of a given type, indicating how large it is or initialize it with the
values from an iterable.

::

    # an array with room for 5 strings
    r = array(string, 5)
    # result: [ '', '', '', '', '' ]


    # an array from an iterable
    l = x * 10 for x in range(3)
    r = array(l)
    # result: [ 0, 10, 20 ]

    # an array casting iterable values to a string
    l = x * 10 for x in range(3)
    r = array(string, l)
    # result: [ '0', '10', '20' ]


AssertionError
--------------

Specific error type used by the ``assert`` macro.


CastError
---------

Specific error type used to signal failures when casting values.


cat
---

Concatenates a list of iterables.

::

    c = cat([10,20], ['a', 'b'])
    # result: [10, 20, 'a', 'b']


enumerate
---------

Obtain an array of key-value pairs from an enumerable. This is usually used
to access the index value when using a ``for`` loop.

::

    l = ('foo', 'bar', 'baz')
    for idx, val in enumerate(l):
        print "$idx: $val"
    # outputs: 0: foo, 1: bar, 2: baz


filter
------

Apply a function to an iterable to filter out items from it in the generated
array. The callback function is called for each element of the iterable, if
it returns a truish value them it's included in the result, otherwise the
element is ignored.

::

    l = range(5)
    r = filter(l, { _ % 2 })
    # result: [0, 2, 4]


Hash
----

Type to model a *hash map*, while a JavaScript's object type does work like a hash
map by default, having a light weight type to reference in our code allows to easily
tell apart those values for which we don't have a specific type from those that are
actually expected to work with hash map semantics.

.. note:: Since we strive for a light weight implementation by using JavaScript object
          semantics, the Hash doesn't accept arbitrary types as keys. Basically keys
          should be restricted to string types, as they are in plain JavaScript code.

The generated code is optimized to avoid using the Hash type methods when possible,
generating instructions operating with plain JavaScript object syntax. There are
however the following helper methods that do not have a direct translation:

::

    # Create a new Hash and initialize it with some values
    hash = Hash(foo: 'Foo', bar: 'Bar', baz: 100)
    # js: {foo: 'Foo', bar: 'Bar', baz: 100}

    # Create a new Hash and initialize it with some key-value pairs
    hash = Hash(('foo' + i, i) for i in range(3))
    # js: {foo0: 0, foo1: 1, foo2: 2}

    # Iterate over the list of keys in the Hash
    for k in hash.keys():
        print k 

    # Iterate over the list of values in the hash
    for v in hash.values():
        print v

    # Iterate over the list of key-value pairs in the hash
    for k, v in hash.items():
        print "$k = $v"

    # Check if a key exists in a hash (uses JavaScript `.hasOwnProperty`)
    if 'foo' in hash:
        print 'foo exists'


join
----

Joins the elements of an iterable to form a string applying an optional separator.
If no separator is given it defaults to a single white space character.

::

    l = ('foo', 'bar', 'baz')
    print join(l)
    # outputs: "foo bar baz"
    
    print join(l, ', ')
    # outputs: "foo, bar, baz"
    
    print join(l, '')
    # outputs: "foobarbaz"


len
---

Obtains the length of a string, array or Hash value. It will obtain the length of
anything that exposes a length property or method. Alternatively, for objects
it will report the number of own properties on them.

::

    l = len([1, 2, 3])
    # result: 3

    l = len({'foo': 'Foo', 'bar': 'Bar'})
    # result: 2

    l = len('hello')
    # result: 5


map
---

Apply a function to every element in an iterable and returns an array with the
results.

::

    l = ('foo', 'bar', 'baz')
    r = map(l, { _.toUpper() })
    # result: [ 'FOO', 'BAR', 'BAZ' ]


NotImplementedError
-------------------

Specific error type raised when an abstract method is not implemented


range
-----

The primary loop construct in Boo is the ``for`` statement, unlike the versions
found in C derived languages it's not possible to indicate initialization and
loop conditions, it always work by obtaining elements from an iterable. The
``range`` builtin generates iterables that implement most common loop cases with
ease.

When a single argument is given it generates an iterable from 0 upto, but not
including, the argument given.

Two arguments indicate an start number (included) and an end number (not included).

Three arguments work as with only two but the third one indicates how the stepping
is done. By default it steps by 1 but we can use any value here, using a negative
one for example allows to generate a decreasing iterable.

.. note:: The BooJs compiler will optimize ``range`` based loops if it's defined
          as the iterable in the ``for`` construct (eg: not assigned to a temporary
          variable), so its performance matches JavaScript's native ``for`` construct.

::

    for i in range(5):
        print i
    # outputs: 0, 1, 2, 3, 4

    for i in range(2, 5):
        print i
    # outputs: 2, 3, 4

    for i in range(2, 10, 2):
        print i
    # outputs: 2, 4, 6, 8

    for i in range(10, 5):
        print i
    # outputs: 10, 9, 8, 7, 6

    for i in range(10, 5, -2):
        print i
    # outputs: 10, 8, 6


reduce
------

Apply a function to every element in an iterable to return a final value. The
callback function receives two arguments, the accumulated value and the next
item from the iterable, the value returned is used as the accumulated value for
the next call.

If not initial value is given it defaults to the first element of the iterable,
making the first call to the function using it as accumulator and the second
element of the iterable.

::

    l = range(5)
    r = reduce(l, { x, y | x + y })
    # result: 10 (0 + 1 + 2 + 3 + 4)

    r = reduce(l, 10, { x, y | x + y })
    # result: 20 (10 + 0 + 1 + 2 + 3 + 4)


reversed
--------

Obtains an array from an iterable where the elements are in inverse order.

::

    l = range(5)
    r = reverse(l)
    # result: [4, 3, 2, 1]


String
------

The string type is directly mapped to JavaScript, there are however a couple of
additions included by the compiler: Multiplication and Formatting.

::

    s = "Foo"
    r = s * 3
    # result: "FooFooFoo"

    r = "Foo {0}" % ('Bar',)
    # result: "Foo Bar"

    r = "Foo {0} {{escaped}} {1}" % range(2)
    # result: "Foo 0 {escaped} 1"


zip
---

Builds an array of arrays by fetching an element for each of the iterables given
as arguments. The algorithm stops when any of the iterables is exhausted, making
it safe for using it with infinite generators.

::

    names = ['John', 'Ivan', 'Rodrigo']
    webs = ['foo.com', 'bar.com', 'baz.com']
    r = zip(names, webs)
    # result: [ ['John', 'foo.com'], ['Ivan', 'bar.com'], ['Rodrigo', 'baz.com'] ]

    # This creates a Hash
    h = Hash(zip(names, webs))
    # result: { 'John': 'foo.com', 'Ivan': 'bar.com', 'Rodrigo': 'baz.com' }

    # Get 3 random numbers (`random_generator` is a never ending generator)
    for i, random in zip(range(3), random_generator()):
        print random
    # outputs: 3 random numbers


Events
~~~~~~

Boo Event's are a way to easily setup delegates in classes, implementing the observer
pattern. Basically they allow registering a callback on them from outside the class but
only firing them from inside the class.

Since it's not clear how to map this to JavaScript there is a very lightweight runtime
support for them. Every event field is mapped to a function that triggers it when called,
exposing two additional methods ``add`` and ``remove`` to handle subscriptions. This is
transparent when using Boo code, adding a subscription is done with the ``+=`` operator
and removing one with ``-=``.

::

    class Foo:
        event click as callable()
        def DoClick():
            click()

    f = Foo()
    f.click += def ():
        print "Clicked!"

To use it from JavaScript code we can use the runtime interface directly:

::

    f.click.add(function () { console.log('Clicked!') })



