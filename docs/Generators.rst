Generators
==========

Generators are really powerful in BooJs, they differ from standard Boo (or C#)
and model instead the pattern found in `Python <http://www.python.org/dev/peps/pep-0342/>`_
or `Mozilla's JavaScript <https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Iterators_and_Generators#Generators.3A_a_better_way_to_build_Iterators>`_.

In summary, every generator becomes a *coroutine* not only able to halt execution
at arbitrary points in order to return a value but also to receive values and
exceptions from the outer context. These features make generators a great primitive
for co-operative multitasking and event driven programming in general, for instance
the :doc:`Async` is built on top of generators.

JavaScript engines, with the exception of Mozilla's and recent V8 builds, do not offer
native support for this kind of generator. The BooJs compiler will instrument the code,
converting the generator to a state machine able to handle halting and resuming execution
at arbitrary points. While the generated code is convoluted it shows to be `pretty fast
on modern browsers <http://jsperf.com/boojs-generator-loop>`_, it runs roughly at half
the speed of an user land ``forEach`` implementation and about 70% the speed of Mozilla's
native generators.


Generator interface
~~~~~~~~~~~~~~~~~~~

BooJs exposes `Mozilla's iterator and generator interfaces <https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Iterators_and_Generators>`_
since they are being standardized in ES6 (aka JavaScript Harmony) there is a chance that
in the future they get adapted to closely follow the standard. Basically a generator
returns a ``GeneratorIterator`` which implements ``Iterator`` for ``next()`` and also
offers ``send(value)``, ``throw(error)`` and ``close()``.


Native support
~~~~~~~~~~~~~~

The compiler only targets standard JavaScript 1.5, not generating alternative code
paths for specific browsers. This is something that will probably change in the future
but currently generators always get instrumented and thus are not as performant as
native implementations, although they aren't as slow as they might seem!

Even if native support is not used, BooJs generators offer a compatible API and hence
should work properly on every environment, including their use with native generator
loop constructs.


Closing generators
~~~~~~~~~~~~~~~~~~

Generators keep state and allow to use ``ensure`` (aka finally) blocks inside them
so there is a need to properly close and dispose them. Boo ``for`` loop construct
understands the GeneratorIterator interface and is able to close them when the
iteration is over. However when manually iterating them you are responsible for
properly closing the generators.

::

    # Infinite generator
    def gen():
        i = 1
        try:
            while true:
                yield i++
        ensure:
            print 'exited'

    # Automatically closed by the compiler
    for _, i in zip(range(3), gen()):
        print i
    # Outputs: 1, 2, 3, 'exited'

    # Manually closing the generator
    g = gen()
    for i in range(3):
        print g.next()
    # Outputs: 1, 2, 3
    g.close()
    # Outputs: exited
