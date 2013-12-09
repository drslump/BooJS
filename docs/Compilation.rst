Compilation
===========

Compilation in BooJs differs from other popular Javascript transpiler solutions in 
that there isn't a one-to-one relation between a .boo file and a .js file. The compiler
will consume any number of .boo files to generate a single output .js file as a result
of the compilation process.

The resulting javascript file is the equivalent to a .Net assembly (a .dll file) or 
a .so file from GCC. It contains all the generated code from the source files, no matter
if it was just one or a dozen. 

If no output filename is given to the compiler, it will use the name of the first source
file given. See the following examples:

::

    $ boojs test.boo
    # Generates test.js

    $ boojs test1.boo test2.boo
    # Generates test1.js

    $ boojs test1.boo test2.boo -o:out.js
    # Generates out.js

If the compiler detects an error while processing the source files it will report it
and exit with an exitcode of 1. A successful compilation won't output anything and
terminate with an exitcode of 0. You can use this exit code values to integrate the
compiler into build systems (ie: your text editor).


Response Files
--------------

Response files (.rsp) are text files that contain compiler switches and arguments. 
Each switch can be on a separate line, allowing comments on lines prefixed with the
``#`` symbol. To instruct the compiler to parse a response file we pass it as an 
argument prefixed with the ``@`` symbol. Response files can be nested by including
an argument line with the ``@`` prefix and the path to another response file.

::

    $ cat cool-project.rsp
    # This is the configuration to compile my cool project
    -embedasm-
    -reference:libs/mylib.js
    -o:coolproject.js
    # Project files to compile
    file_a.boo
    file_b.boo

    $ cat cool-project.verbose.rsp
    -verbose+
    @cool-project.rsp

    $ boojs -debug @cool-project.verbose.rsp

.. note::
  This mechanism is a great way to automate simple builds without using a dedicated
  build tool. Even when using a build tool they can simplify the integration of 
  the BooJs compiler.



Compilation metadata
--------------------

Boo is a statically typed language, in order for the compiler to check if the code
complies with the type contracts it needs to know what the valid types are for using
a symbol. Since Javascript is not typed, once we have compiled some Boo code the 
compiler wouldn't be able to apply those type checks without having access to the 
original .boo files. To avoid having to compile again and again all the source in
your project the compiler will embed type information as a comment ``//# booAssembly``
in the generated javascript file, this allows the compiler to have all the needed 
information when referencing an already compiled library.

This type information is quite heavy in size, so it's recommended to strip it 
before publishing the files for its use in production, since it's just needed by the
compiler and in any case used at runtime. Most javascript *bundlers* or optimizers will
take care of removing comments in the javascript code, so while BooJs does not offer
a tool for stripping this info it is a trivial operation if you include one of these
optimizers in your build process.


Improving the code-compile-test cycle
-------------------------------------

In order to ease your development work flow you can instruct the BooJs compiler to
keep watching your project files for modifications, triggering automatically a
compilation on every change in the source files. By using the `--watch` command line
flag, the compiler will keep running after the first compilation, monitoring 
for changes in all the involved files, automatically compiling a new version of the
program if a change is detected.

::

	$ boojs --watch -o:test.js test1.boo test2.boo

In this execution mode compiler messages are outputted to the ``stderr`` using the 
yellow color for warnings and the red color for errors.

To exit the watcher mode just press ``ctrl-c`` to terminate the compiler process.

.. note:: Since the compiler generates *assemblies* from the source files, it can't 
          monitor a directory for new files and the such. If your project consists 
          of different assemblies you will have to launch the compiler in watcher mode 
          for each one of them, terminating and launching them again if you add, delete 
          or rename any source file.


SourceMaps
----------

Google Chrome and Firefox (other browsers will probably support it shortly) offer 
support for mapping a Javascript file with the files that were used to generate it, 
.boo files in our case. When we enable the sourcemap feature in the compiler two 
things will happen, first a new file will be generated containing a json payload 
with the sourcemap metadata (version 3), secondly a special comment will be included 
in the generated javascript file indicating the location of the sourcemap metadata.

When debugging a javascript file in a sourcemap supporting environment, we would
be able to operate on the original Boo code instead of the generated Javascript one, 
including the option to interactively debug the program step by step based on Boo
statements.

::

	$ boojs -o test.js -sourcemap:test.js.map *.boo
	# Generates test.js and test.js.map

.. note:: If we are using the ``Boo.debug.js`` runtime addon and we compile in 
          debug mode, we will be given a processed stack trace when an uncaught 
          exception occurs, mapping the Javascript to the original Boo code. This 
          functionality should work independently of the native support for 
          sourcemaps in the executing environment.


Runtime and dependencies
------------------------

BooJs requires a small runtime for the generated code to work, besides any other 
dependencies your program may be using (ie: jQuery). These dependencies should be 
provided in the executing environment before loading the generated code, by default
BooJs won't load them automatically or include them as part of the generated file.

At the bare minimum you will need to make sure that the ``Boo.js`` file has been 
loaded. There is an optional runtime ``Boo.debug.js`` file which can help in debugging 
problems, which you can use while developing.


Generating code for production
------------------------------

The compiler generates performant code by default if you don't use the ``--debug`` 
switch. However it tries to generate Javascript code that is easy for a human
to read, in order to ease troubleshooting problems. If you're targeting an 
environment where size matters (web site, mobile devices, ...) you will most
probably benefit from using a Javascript optimization tool like Google Closure
or UglifyJS.

These tools will first of all remove metadata included in the form of comments
which is only needed by the compiler. Moreover they will mangle variable names
to make them shorter and thus reducing the final code size. Some of them will
even reduce the size by removing dead code (not used types for example).

.. note:: The compiler will try to generate code that is safe to process thru 
          any of these optimizers, so you won't have to worry about configuring 
          them to produce a valid result.



