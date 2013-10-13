Overloading
===========

Method overloading
------------------

  Allows defining several functions with the same name which differ from each other in 
  the types of the input arguments.

Boo method overloading mechanism takes into account differences in the input arguments
of methods with the same name, it does not take into account differences in the return
types of those methods. Moreover, when looking for the best candidate in an instance, 
it will choose one from the target instance type and will only look for candidates in 
inherited types if it couldn't find one.

Each overloaded method is assigned an unique suffix, so an overloaded method named 
``foo`` with two different signatures will generate two additional methods named 
``foo$0`` and ``foo$1``. The compiler will try to find the best candidate at compile 
time, however there are times when that's not possible, for instance when the target 
object is *ducky*, performing the resolution at runtime. This has obviously a cost, so 
try to avoid mixing overloading and duck typing in performance critical sections.

When the overloaded method is public and is used from external code, the calling site
cannot be updated to target a specific version of the method. Instead, calls to the
method make use of a runtime mechanism to forward the call to a valid candidate.

.. note:: The current implementation of the runtime dispatching only takes into
          account the number of arguments, not their types. This shortcoming will 
          be removed in the future, implementing a more advanced resolution.


