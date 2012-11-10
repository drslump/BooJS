# BooJs

![BooJs logo](https://raw.github.com/drslump/boojs/master/extras/logo.png)

Javascript backend for [Boo](http://boo.codehaus.org).

You should read [Boo's manifesto](http://boo.codehaus.org/BooManifesto.pdf) to 
start to grasp what this nice language is about and the philosophy behind it.

> Boo is a new object oriented statically typed programming language ... with a
  python inspired syntax and a special focus on language and compiler extensibility.

Boo's syntax is readable and expressive, mixing imperative, object oriented 
and functional idioms. One of the motos of the language is that if the compiler 
can figure out what you want it should, avoiding the need for verbose and 
repeatitive syntax.

One nice feature of Boo is that it's statically typed but allows the developer to 
opt-out of it and use dynamic typing when needed (or viceversa). This means that 
it's possible to build a large statically typed code base with it but still offer 
a dynamic feeling to it, integrating nicely with external libraries. Moreover it 
supports _type inference_ so most of the time you end up writing type checked code 
without even noticing it.

Developing large code bases with Javascript is hard, even with the current set of 
tools and frameworks there are just so many times when a statically typed language 
would find subtle bugs at the compiling stage instead of when testing. Morever, 
people from many different backgrounds are put together to develop large applications 
and not all of them embrace or are trained in using the good parts of the language. 
The situation is somewhat improved by the use of languages like CoffeeScript, although 
for the overhead of adding a compilation step they don't offer much more than a nicer 
syntax. Boo is great because it will not only give you a nicer, more structured syntax 
but also has a pretty intelligent compiler to help you in your development.

## Documentation

BooJs specific features are being documented in the [github wiki](/drslump/boojs/wiki/) and automatically
published in [ReadTheDocs](http://boojs.readthedocs.org).

## Requirements

The compiler works on Windows, Mac and Linux using the .Net or Mono runtimes.

  - .Net 4.0 or Mono 2.x

## Building

    $ msbuild src/boojs.sln   (xbuild in Mono)

## Running

    $ boojs <file>.boo

## Roadmap

[![Build Status](https://travis-ci.org/drslump/BooJS.png)](https://travis-ci.org/drslump/BooJS)

  - Imperative idioms - 95%
  - Functional idioms - 90%
  - Closures (annonymous functions) - 75%
  - Classes
  - Namespaces and packaging - 75%
  - Method overloading - 20%
  - Operator overloading - 95%
  - Events (Delegation / Observer pattern)
  - Source Maps - 95%
  - Meta-programming (Macros, Syntactic attributes) - 70%
  - Preprocessor - 10%
  - Type hinted interfaces for common Javascript APIs (DOM, jQuery, HTML5...) 50%
  - Reduce the size of the runtime by making the compiler more intelligent
  - Generators - 90%
  - Support for optional and named params

