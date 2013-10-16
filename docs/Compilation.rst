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
your project the compiler will embed type information as a comment ``//@ booAssembly``
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

In this execution mode compiler messages are outputed to the ``stderr`` using the 
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
to read, in order to ease troubleshothing problems. If you're targetting an 
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


IDE Helper
----------

Boo is a complex language to support properly on IDEs since it relies on type 
inference and macro expansions, thus it's not trivial to offer a solid auto 
completion mechanism for it. The compiler offers a *hints server* mode via the 
``-hint-server`` switch to ease the development of support for BooJs in IDEs 
and editors, in this mode the compiler serves commands from *stdin* outputting 
the results in *stdout*.

For better results run the compiler as you would normally, including references,
adding the ``-hint-server`` switch. It won't actually generate any output file,
instead it will keep listening for hint commands.

.. note:: In order to offer hints for different files in the current project too, 
          make sure to explicitly define an output assembly file in the command
          line or include as a reference the last successful compilation of the 
          project. Even if the assembly does not have the latest changes it
          usually works well enough to be useful.


Protocol
~~~~~~~~

Protocol is Json based, where each line to *stdin* is a Json message representing
a command query and every one to *stdout* is a Json message representing the 
result. Errors are written to *stderr*.

The server is single threaded thus all queries are served in the order they are
received. You should not issue new commands to *stdin* until the whole results from 
the previous command has been consumed or an error has been reported via *stderr*.

.. note:: Debug information can be reported via *stdout* and *stderr* with lines 
          prefixed with a ``#`` character. Keep this in mind when processing the 
          results from the hints server. A debug message does not terminate the 
          previous command issued. If received via *stderr* it should be considered
          as a *warning*, while on *stdout* just provide additional information
          mostly used to help debug an integration.

.. note:: Even if in the examples below we have Json messages formated in multiple 
          lines for readability, the actual protocol requires them to be serialized 
          into a single line.

A query command is modeled as follows, not all fields are required, see each command
documentation to see an example of what is needed in each case.

::

    {
      "command": "parse",           # The command to run
      "fname": "/path/to/foo.boo",  # The name of the file
      "code": "import System\n..."  # The source code
      "codefile": "/tmp/file.tmp"   # If code is not given it tries to obtain it from this file
      "offset": 653,                # Byte based offset (0 based count)
      "line": 10,                   # Source code line (1 based count)
      "column": 10,                 # Source code column (1 based count)
      "extra": true,                # True to receive additional information for hints (location, docblock)
      "params": ["foo", 10]         # Additional params for the command              
    }


Parse command
~~~~~~~~~~~~~
Parse the given file reporting back any errors or warnings found in the process.

.. note:: Query with ``extra`` set to ``true`` to use the more complex compiler pipeline 
          to detect warnings and errors regarding type resolution and not only syntax.

::

    {
      "command": "parse",
      "fname": "/path/to/foo.boo",
      "codefile": "/path/to/foo.boo"
    }

::

    { 
      "errors": [{
        "code": "BCE0058",
        "message": "foo is not a valid method",
        "line": 26,   # Count is 1 based
        "column": 12  # Count is 1 based
      }],
      "warnings": []
    }


Outline command
~~~~~~~~~~~~~~~
Generate an outline for the types and members contained in a file. The result is 
a node tree structure having the file module as root node.

::

    {
      "command": "outline", 
      "fname": "/path/to/foo.boo",
      "codefile": "/path/to/foo.boo"
    }

::

    {
      "type": "Module",
      "name": "foo",
      "line": 0,
      "length": 66,  # Number of lines this element spans
      "members": [{
        "type": "Import",
        "desc": "jQuery",
        "line": 10,
        "length": 1
      }, {
        "type": "ClassDefinition",
        "name": "Foo",
        "line": 13,
        "length": 42,
        "members": [{
          "type": "Method",
          "name": "bar",
          "line": 19,
          "length": 6,
          "members": []
        }]
      }]
    }


Globals command
~~~~~~~~~~~~~~~
Obtain hints for all global symbols in a file, this includes the types and 
methods defined in the file and the ones imported via import statements.

.. note:: Top level namespaces from standard assemblies are not reported 
          unless they are explicitly imported in the file (ie: System)

::

    {
      "command": "globals",
      "fname": "/path/to/foo.boo",
      "codefile": "/path/to/foo.boo"
    }

::

    { 
      "scope": 'globals',
      "hints": [{
        "node": "Class",
        "type": "Test.Foo",
        "name": "Foo",
        "info": "class, final"
      }, {
        "node": "Method",
        "type": "Test.bar",
        "name": "bar",
        "info": "Void alert(System.String)",
        "doc": "method docstring contents",
      }]
    }


Namespaces command
~~~~~~~~~~~~~~~~~~
Obtain hints for available top level namespaces in the current compiler.

::

    {
      "command": "namespaces",
      "fname": "",
      "code": ""
    }

Response follows the same format as Globals


Builtins commad
~~~~~~~~~~~~~~~
Queries for available primitive types and builtin methods in the current compiler.

::

    {
      "command": "builtins",
      "fname": "",
      "code": ""
    }

Response follows the same format as Globals 


Locals command
~~~~~~~~~~~~~~
Obtain hints for local symbols available at a given line in the file, including
method parameters and symbols available via closures.

::

    {
      "command": "locals",
      "fname": "/path/to/foo.boo",
      "codefile": "/path/to/foo.boo",
      "line": 13  # Line number to check (count is 1 based)
    }

The response follows the same format as for the Globals command.


Complete command
~~~~~~~~~~~~~~~~
Obtain hints for all the possible candidates at a given position in the file. This 
command is scope sensitive, it will detect if we are in an import statement to provide
namespaces, writing parameter declarations, type references, ... The detected scope
is reported as part of the response.

.. note:: If you're developing an editor plugin and you're already caching global 
          symbols to improve the performance, you can provide ``true`` as first 
          parameter to skip collection of global candidates. This allows to use 
          the reported scope to complete the list with your cached results.

::

    {
      "command": "members",
      "fname": "/path/to/foo.boo",
      "code": "...",
      "offset": 345  # Byte offset in the file
    }

The response follows the same format as for the Globals command, except that the scope field
is populated with the detected scope for the given offset (for example: members or import)

.. note:: The offset is byte based, make sure you account for the correct value
          if your file contains multi byte characters.


Entity command
~~~~~~~~~~~~~~
Obtain all the information about a given symbol, very useful to implement a "Go To" or
showing additional information when hovering over a symbol.

.. note:: It may not be possible for the compiler to know which exact entity is being
          referenced at compile time if there are multiple possibilities (overloads).
          The result is always a list which can contain zero or more elements.

.. warning:: The compiler only reports back location information (file, line, column)
             for entities declared in the same file being analyzed. Support for external
             symbols require to have the optional Cecil assembly available and symbol 
             files for your project (.pdb or .mdb files).
::

    {
      "command": "entity",
      "fname": "/path/to/foo.boo",
      "codefile": "/path/to/foo.boo",
      "line": 10,
      "column": 34  # Should match the start of the symbol
    }

::

    { 
      "hints": [{
        "node": "Method",
        "type": "Test.bar",
        "name": "bar",
        "info": "Void alert(System.String)",
        "doc": "method docstring contents",
        "file": "/path/to/foo.boo",
        "line": 33,
        "column": 10
      }]
    }