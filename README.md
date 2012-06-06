# BooJs

Javascript backend for Boo.

You should read [Boo's manifesto](http://boo.codehaus.org/BooManifesto.pdf) to 
start to grasp what's it about.

> Boo is a new object oriented statically typed programming language ... with 
  a python inspired syntax and a special focus on language and compiler extensibility.

Boo's syntax is very readable and quite expressive mixing imperative, object
oriented and functional idioms. One of the motos of the language is that if the 
compiler can figure out what you want it should do it, avoiding the need for verbose 
and repeatitive syntax.

One nice feature of Boo is that it's statically typed but allows to opt-out of 
it and use dynamic typing when needed. This means that it's possible to build
large code bases with it but still offer a dynamic feeling, integrating nicely with 
external libraries. Moreover it supports _type inference_ so most of the time you end 
up writing type checked code without noticing it.

Developing large code bases with Javascript is problematic, even with the current
set of tools and frameworks there are so many times when a statically typed 
language would find subtle bugs at the compiling stage instead of when testing.
Morever, people of many different backgrounds are put together to develop
large applications and not all of them embrace or are trained in using the good 
parts of the language. The situation is somewhat improved by the use of languages
like CoffeeScript, although for the overhead of adding a compilation step they 
don't offer much more than a nicer syntax. Boo is great because it not only
will give you a nicer, more structured, syntax but also has a pretty intelligent
compiler to help you in your development.


## Requirements

The compiler works in Windows, Mac and Linux using the .Net or Mono runtimes.

  - .Net 2.0 or Mono 2.x
  - Nant

## Building

    $ nant

## Running

    $ ./boojs <file>.boo

## Roadmap

  - Imperative - 85%
  - Functional idioms - 20%
  - Closures (annonymous functions) - 50%
  - Classes
  - Namespaces and packaging
  - Method Overloading
  - Events (Delegation / Observer pattern)
  - Source Maps - 30%
  - Meta-programming (Macros, Syntactic attributes)
  - Preprocessor
  - Type hinted interfaces for common Javascript APIs (DOM, jQuery, HTML5...)
  - Reduce the size of the runtime by making the compiler more intelligent
  - Generators (optional) - 10%
  - Operator overloading (optional)
  - Add support for optional and named params (optional)

