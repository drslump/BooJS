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

