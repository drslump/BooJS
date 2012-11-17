"""
foo: FOO
bar: 2
baz: 
-foo: FOO
-bar: 2
-baz: 
"""

import jQuery

def named(opts as Hash):
    named('', opts)

def named(prefix as string, opts as Hash):
    for v, k in opts:
        print "$(prefix)$k: $v"

named(foo: 'FOO', bar: 2, baz: null)
named('-', foo: 'FOO', bar: 2, baz: null)

# External methods
jQuery.ajax('http://google.com', one: 1, two: 2)
