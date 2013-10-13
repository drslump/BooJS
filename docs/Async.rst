Async library
=============

BooJs includes a simple yet powerful asynchronous library modeled after the `Promises/A
CommonJS spec <http://wiki.commonjs.org/wiki/Promises/A>`_ also known as *thenables*. You 
can read more about this asynchronous programming pattern on 
`Wikipedia <http://en.wikipedia.org/wiki/Promise_(programming)>`_.

By supporting the *Promises/A* spec we ensure compatibility with some of the most popular
JavaScript frameworks like Dojo or jQuery. Other frameworks implementing the *deferred*, 
*promise*, *future* or *task* patterns can be easily modified to be made compatible with
*Promises/A* for most use cases.

The Async library is exposed as an optional namespace, not included by default by the
compiler, which you can use in your own code just by importing the ``Async`` namespace
and loading the ``Boo.Async.js`` file in your environment.


Deferred
~~~~~~~~

The ``Deferred`` class allows to create, control and resolve *promises* which can be
consumed by your own code or passed on to third party libraries that understand the
*Promises/A* spec. 

::

    def make_async(v):
        # Create a new deferred
        defer = Deferred()
        # Launch the async job
        setTimeout({ 
            # Resolve the deferred with the final value
            defer.resolve(v) 
        }, 1000)
        # Return the deferred promise which can be observed
        return defer.promise

    # Obtain a promise
    promise = make_async('foo')
    # Register a callback to observe the successful resolution of the promise
    promise.done({ x | print x })
    # Register a callback to observe the wrongful resolution of the promise
    promise.fail({ x | print 'Error:', x })

.. note:: 
    Unlike some implementation that focus on raw performance (ie jQuery), ``Deferred`` 
    works internally as a tree instead of a list. Each time you attach a callback to a 
    deferred a new one is created internally returning its public interface, a ``Promise``, 
    this allows to model complex flows avoiding side effects.

.. note::
    A common pitfall when using the promise pattern is that some errors might go
    unnoticed if we are not very careful to observe failures on every promise generated.
    To avoid this you can assign a global callback in ``Deferred.onError`` to act upon
    any rejected promise that isn't explicitly controlled. It's the equivalent to a
    handler for uncaught exceptions. By default, if no custom handler is assigned,
    a exception is raised with the reported error.


Promise
~~~~~~~

A ``Promise`` object is the public interface of a ``Deferred``, there is a 1:1 
relationship between them. While a ``Deferred`` allows to control its cancellation, 
rejection and resolution a ``Promise`` only allows to register our interest in its 
resolution (successful or not).

The *Promises/A* spec just specifies that a ``Promise`` object must expose a public
method called ``then`` which receives 3 arguments: *successCallback*, *failureCallback* 
and *progressCallback*. This simple design makes it trivial to share promises
between third party libraries, like jQuery for instance, allowing to observe the
resolution of an asynchronous task with ease.


Utilities
~~~~~~~~~

enqueue
-------

This simple method allows to defer the execution of a callback until the stack is 
empty. This is specially useful when you want to trigger an action just after a
configuration step has completed. For instance, this method is used internally by
``Deferred`` to resolve them, that's why they can be used also with immediate values.

::

    d = {}
    enqueue({ d.run() })
    d.run = def():
      print 'Foo!'
    # d.run() will called now

.. note:: In a browser environment it will use ``setImmediate`` or ``setTimeout`` 
          with a timeout of 0. For Node it will use ``process.nextTick``.

when
----

A common pattern is to wait until two or more action have completed before 
continuing. The ``when`` method will produce a ``Promise`` that gets resolved 
only when all the arguments given are resolved successfully. If any of them
is rejected the ``Promise`` is rejected also and the other arguments are
*canceled*.

::

    p = when( jQuery.get('/data/a'), jQuery.get('/data/b'), 'immediate value' )
    
    p.done def(results):
      a, b, immediate = results
      print a, b, immediate
    
    p.fail def(error):
      print 'An error occurred fetching data:', error

.. note:: ``when`` can also be used as a shortcut to wrap any value in a
          promise which gets almost instantly resolved.

sleep
-----

This method generates a ``Promise`` that gets resolved after the given milliseconds.
It can be used to delay the execution of some code without blocking the execution
thread.

::

    p = sleep(10s)
    p.done:
        print 'Woke up after 10 seconds'

    # It also supports providing a callback directly
    sleep 10s:
        print 'Woke up after 10 seconds'


Async/Await
~~~~~~~~~~~

One of the nicest features of the Async library is its implementation of the Async/Await 
pattern. Modeling your logic around *promises* is a nice way to support asynchronicity,
however it forces you to replace the language native flow control mechanisms by those
of the ``Deferred`` API. The Async/Await pattern removes that limitation, allowing you to
write *promise* based code as if they were synchronous operations.

Under the hood the pattern makes use of coroutines (constructed via generators) to suspend
and resume the execution of code at any point in a function based on the result of a 
``Promise``.

When we annotate a method as ``async`` we are telling the compiler that we want to control 
its execution in a special way, suspending it when an ``await`` keyword is found until 
its value is resolved. In other words, the ``await`` keyword indicates that we want to wait 
at that point until the given ``Promise`` object is resolved, avoiding the need to chain
callbacks to control the program logic flow.

::

    [async] def fetch(url):
        print "Fetching $url"
        try:
            # jQuery's ajax methods are Promises/A compatible
            await data = jQuery.get(url)
            print data
        except ex:
            print 'Error:', ex

The code above is roughly equivalent to the following one:

::

    def fetch(url):
        print "Fetching $url"
        promise = jQuery.get(url)
        promise.done = def(data):
            print data
        promise.fail = def(error):
            print 'Error:', error

Even in this simple example the benefits of the Async/Await version are obvious. The 
complexity of using the promise API is hidden from us, with the added benefit that
every *async* method always returns a *promise* itself, thus it's very easy to 
compose complex flows with them.

::

    def fetch(id):
        print 'Fetching data'
        await data = jQuery.get('http://ajax.com/' + id)
        return data

    def update(id):
        await data = fetch(id)
        data.foo = 10
        await jQuery.put('http://ajax.com/' + id, data)
        print 'Data updated'


Another point where this pattern excels is in the handling of error conditions.
There is no need to observe the promises for failures, using the native try/except
mechanism we can control failures in a clean way, even maintaining a meaningful 
stacktrace to troubleshot any problem.

.. note:: 
    The ``await`` keyword also works for multiple values, by using ``when`` under the
    hood. This means that we can easily parallelize asynchronous operations and only
    resume execution when all of them have completed.
