Modules
=======

Boo follows a strict mapping of one module per file, in other words, each source
file is a module. From its .Net roots however there is also the concept of
namespaces, which allow to expose multiple modules under a single export point.

In BooJs that mechanism is respected and mapped to what is known as the 
`AMD pattern <https://github.com/amdjs/amdjs-api/wiki/AMD>`_ in the Javascript world.
The reason why this pattern was chosen instead of something like Node.js ``require``
is that BooJs code can be targeted to run on a browser too, where synchronous
loading of code is not widely supported.

Here is an example Boo module and the generated Javascript code with annotations:

::

    namespace example

    import myapp

    def foo(s):
        notify(s)

    foo("Hello")

::

    // Namespace serves as ID and is mapped to exports so we can augment it
    // Boo runtime is always passed as a dependency
    // Imports are passed as additional dependencies
    Boo.define('example', ['exports', 'Boo', 'myapp'], function (exports, Boo, myapp) {
        // Type definitions of the module
        function foo(s) {
            myapp.notify(s);
        }
        // Public types are exported
        exports.foo = foo;
    });

    // Namespace is mapped to exports
    // Boo runtime is again always passed as a dependency
    // Imports are passed as additional dependencies
    Boo.require(['example', 'Boo', 'myapp'], function (exports, Boo, myapp) {
        // Executable portion of the module
        exports.foo("Hello");
    });


One difference with the AMD spec is that ``define`` and ``require`` are not global symbols
but instead are referenced from the Boo runtime (eg. ``Boo.define``). This is done to avoid
a dependency or conflict with an AMD loader in the environment, BooJs includes all the needed
functionality to manage AMD style dependencies. If you wish to use a more powerful loader you
can just point ``Boo.define`` and ``Boo.require`` to `require.js <http://requirejs.org>`_ for
example.

BooJs default AMD loader does not automatically fetch dependencies from disk or a web server,
it expects all the dependencies to be loaded up front, its job is only to resolve them in the
correct order. Since in BooJs the deployable unit is an *assembly* and not a *module* this
works quite well, you just need to remember to load all the generated assemblies in your
environment. For automatic loading of dependencies you can easily integrate with
`require.js <http://requirejs.org>`_ or any other module loader that conforms to the AMD
pattern.


.. note:: For Node.js environments a custom wrapper for the loader is in the roadmap, it will
          take care of automatically importing referenced dependencies.
