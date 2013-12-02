"""
baz
bar
foo
0
1
2
Waited for 0.1
Waited for 0.2
/foo
BAR: foo
/bar
BAZ: bar
/baz
"""

import Async

# Either as an attribute or a simple function
[async] def foo():
    print 'foo'
    try:
        for i in range(3):
            print i

        for delay in (100ms, 200ms):
            await delay = sleep(delay)
            print "Waited for 0.$(delay/100)"
    except ex:
        print 'Error', ex

    print '/foo'
    return 'foo'

[async] def bar():
    print 'bar'
    await data = foo()
    print 'BAR:', data
    print '/bar'
    return 'bar'

[async] def baz():
    print 'baz'
    await f, _ = bar(), sleep(10ms)
    print 'BAZ:', f
    print '/baz'


baz()
