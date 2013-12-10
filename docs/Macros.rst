Macros and Syntactic Attributes
===============================

By default some macros are made automatically available for their use in Boo without
importing any namespace. Some of them are equivalent to standard Boo while others 
are only available when using the BooJs compiler.

.. note:: Macros, Meta-Methods and AST Attributes are resolved at compile-time, this
          means that they are executed as part of the compilation and thus not part
          of the generated JavaScript code. They work by transforming the program syntax
          tree, refer to the standard Boo documentation to learn more about them.


Macros
~~~~~~

assert
------

Use this macro to ensure some condition applies when compiling in debug mode. If the 
given condition fails it will raise a ``Boo.AssertionError`` exception. When compiling
without the debug switch the assertion is removed from the generated source code.

::
  
    assert arg > 10
    # Raises Boo.AssertionError('arg > 10')
    assert arg < 100, 'Argument must be less than 100'
    # Raises Boo.AssertionError('Argument must be less than 100')


const
-----

Boo's syntax doesn't allow to define variables at the module level, the compiler will 
interpret such declarations as the start of the module entry point. This macro allows
to work around this issue and bind static variables to the current module.

::

    namespace MyNS

    const foo = 10
    # Declares MyNS.foo as an int with a value of 10
    const foo as string = 'foo'
    # Declares MyNS.foo as a string with a value of 'foo'


global
------

Unlike JavaScript, Boo's compiler will complain if you reference a symbol that hasn't
been previously declared either in the current module or imported from another namespace.
In order to integrate Boo code with external symbols defined somewhere else in your 
execution environment, the ``global`` macro provides the means to make those symbols
available in the code.

::

    global jQuery   # jQuery is available with a type of duck
    jQuery('#foo').html('Hi there!')

    global MY_FLAG as int   # MY_FLAG is available with a type of int
    print MY_FLAG + 10


ifdef
-----

Allows to define blocks for conditional compilation by evaluating the condition
against the compiler defined symbols. You can use your own defined symbols with
the ``-D:symbol`.

If the condition evaluates to false the contents of the block are removed from
the compilation unit.

::

    ifdef DEBUG:
        print "Debug mode enabled"

    ifdef not WINDOWS and DEBUG:
        print "Compiling on a non-windows system"


match
-----

BooJs automatically exposes the ``match`` macro from Boo.Lang.PatternMatching. This
macro allows to use pattern matching in your code completely at compile time. You can
learn a few of the basics from `this mailing list message <https://groups.google.com/d/msg/boolang/DsvE0SFVXPg/XvraEpRP0vQJ>`_.


new
---

JavaScript allows to instantiate new objects in a variety of ways, when interfacing
external code without using type definitions for it we may need to indicate the
compiler how it should call a constructor function.

The ``new`` symbol is not actually a macro but a *meta-method*, the syntax for
applying it is the same as for functions but it's resolved at compile-time, so it 
doesn't appears in the generate JavaScript code.

Since Boo already has a ``new`` keyword, used to define members with the same name
as one in the inherited type, we can't use it directly to flag a constructor. To use
it we have to prefix ``new`` with ``@`` to tell the compiler that we are referencing
the meta-method instead of the keyword.

::

    global Coords

    obj = Coords(10, 20)
    # js: obj = Coords(10, 20); 

    obj = @new( Coords(10, 20) )
    # js: obj = new Coords(10, 20);


preserving
----------

Solves the common problem of temporally backing up some variables to perform an action.

::

    x = 'foo'
    y = [10, 20]
    preserving x, y[1]:
        x = 'bar'
        y[0] = 50
        y[1] = 60

    print x    # 'foo'
    print y    # [50, 20]


print
-----

The ``print`` macro outputs the given arguments using the ``console.log`` function if
available in your environment.

::

    foo = 'DrSlump'
    print "Hello", foo   # Hello Drslump


trace
-----

Very similar to ``print`` but only outputs when in *debug* mode. The message is 
prefixed with the filename and line number where the macro was used.

::
    
    trace 'hello there'   # filename.boo:11 hello there


with
----

Even though the ``with`` statement is considered evil in modern JavaScript, this macro
serves a similar purpose avoiding the drawbacks of its JavaScript sibling. It sets a 
value as default target for expressions without one but does so explicitly by prefixing 
the expressions with a dot.

::

    with jQuery:
      .each({x| print x})   # Converted to jQuery.each()
      each()                # Looks for a method named "each"

    with foo = jQuery('#foo'):
      .html('Hi there!')    # Converted to foo.html('Hi there!')


Attributes
~~~~~~~~~~

Extension
---------

Like in C# it's possible to *extend* a type with new methods without modifying the
type's hierarchy chain. The first argument of the method defined as a extension is
the type to which that method should be attached. If the compiler doesn't find a 
proper method defined in the extended type it will check the extensions for a proper
match.

::

    [extension] 
    def toISO(date as Date):
      return date.getFullYear() + date.getMonth() + date.getDate()

    [extension]
    def incr(date as Date, seconds as int):
      date.setTime( date.getTime() + seconds*1000 )

    d = Date()
    print d.toISO()     # Converted to: print toISO(d) 
    d.incr(3600)        # Converted to: incr(d, 3600)
