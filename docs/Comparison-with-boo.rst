Comparison with Boo
===================

BooJs strives to be as much compatible with Boo as possible, there are however
a few differences, some are the result of the project design, others are
mandated by performance reason and then there are a few *improvements* to the
language that haven't yet be ported to standard Boo.


Type system and standard library
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Probably the biggest difference is that BooJs uses the JavaScript type system
and standard library instead of those in .Net. This is by design, it ensures
proper performance and JavaScript's eco system of libraries is very rich anyway.
Besides, the scope of the .Net library is huge and porting it to JavaScript
would require an IL to JavaScript compiler while BooJs works at a much higher
level.

These differences mean that you can't compile the same source files with Boo and
BooJs without somehow abstracting those differences. Of course it's possible to
create your own proxy objects and extension methods to emulate the JavaScript 
types for Boo or vice versa.


Primitive types
~~~~~~~~~~~~~~~

The following boo literal types are not defined in BooJs: char, sbyte, byte,
short, ushort, long, ulong and single. Only ``int``, ``uint`` and ``double`` are
supported as number types.

At the runtime, standard JavaScript rules apply when working with number types,
in summary all numbers are actually 64bit doubles with a 53bits mantissa, when
used with binary arithmetic operators all numbers are casted to 32bit integers.

.. note:: There is an additional BooJs literal type with the symbol ``any``. It's
          just an alias for ``duck``.


Named parameters
~~~~~~~~~~~~~~~~

Boo supports the following syntax to initialize object properties when calling
a constructor.

::

    f = Foo("hello", PropOne: 100, PropTwo: "value")
    # Translates to:
    # f = Foo("hello")
    # f.PropOne = 100
    # f.PropTwo = "value"

In BooJs it is also possible to use named parameters for plain methods, however
when used with a non-constructor the parameters are converted to a Hash, there
is no actual matching for the referenced method parameter names. The reason is
that BooJs tries to simplify the integration with JavaScript code and there isn't
a clean way to obtain the argument names for an arbitrary function.

::

    foo(100, x: 10, y: 20)
    # Translates to:
    # foo(100, {"x": 10, "y": 20})  

The use of a last argument accepting a hash with additional options is actually
a pretty common pattern in JavaScript libraries, so this compiler transformation
turns out to be very useful to produce readable code but still allowing natural
integration with JavaScript code.


Generators
~~~~~~~~~~

Check out the :doc:`specific documentation about them <Generators>`. In essence the
changes are compatible with plain Boo.


Safe Access / Existential operator
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

BooJs supports a new unary operator, represented by a question mark, that allows to
perform two common action: check if a value is not null and protect against accessing
null/undefined references.

By suffixing an expression with ``?`` the compiler will convert the expression to a
test checking if the expression is different to null. This is good way to ensure we
do proper null element comparisons, working around issues with 0 and an empty string
evaluating as false in JavaScript.

If the ``?`` symbol appears before a dot, an open parenthesis or an open square bracket
it will protect it to ensure that the next part of the expression is only accessed if
the previous part is not null, otherwise a null value is returned.

Often times we have to work with nested structures, which might have some paths nulled,
instead of manually checking every step of the path before accessing it we can use the
safe access operator to do it for us.

::

    # evaluates to a boolean by testing if `foo` is not null
    foo?

    # calls `foo.bar()` if foo is not null
    foo?.bar()

    # evaluates to null if any of the nested objects is null
    if person?.address?.city == 'Barcelona':
        pass


Verbatim JavaScript code
~~~~~~~~~~~~~~~~~~~~~~~~

Every now an then there is the odd case where we can't map some JavaScript code to
BooJs, or perhaps we are just prototyping something and we want to copy-paste some
snippet of code. BooJs will include code quoted with a backtick ````` in the generated
JavaScript code without modifying it.

.. note:: The behavior for backtick quoted strings in plain Boo is to define a string
          literal without any special handling for escape sequences.

.. warning:: This behavior might change in a future version by requiring to wrap the
             JavaScript code with a call to a ``js`` function. This will allow to keep
             the original use for backtick strings and to build JavaScript code with
             string interpolation.

::

    a = 100 + `10`
    `alert(a)`
    # generates:
    # var a = 100 + 10
    # alert(a)

    # We can include multi line snippets too
    a = `
        [ 'foo',
          'bar'
        ]
    `
