"""
foo
bar
baz
10,20
"""
def foo():
    print 'foo'
    def bar():
        print 'bar'
        def baz():
            print 'baz'
        baz()
    bar()

def x(*args):
    def y(*args):
        def z(*args):
            print args
        z(args)
    y(args)

foo()
x(10, 20)
