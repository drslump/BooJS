"""
Test 0
=====
Test 1
begin outer try
outer ensure
Caught: Exception from outer ensure
=====
Test 2
begin outer try
begin middle try
middle ensure
outer ensure
Caught: Exception from outer ensure
=====
Test 3
begin outer try
begin middle try
innermost try
innermost ensure
middle ensure
outer ensure
Caught: Exception from outer ensure
=====
Test 4
begin outer try
begin middle try
innermost try
innermost try continues
innermost ensure
middle ensure
outer ensure
Caught: Exception from outer ensure
=====
"""

def nestedEnsures():
    try:
        yield "begin outer try"
        try:
            yield "begin middle try"
            try:
                yield "innermost try"
                print "innermost try continues"
            ensure:
                print "innermost ensure"
                raise "Exception from innermost ensure"
            yield "end middle try"
        ensure:
            print "middle ensure"
            raise "Exception from middle ensure"
        yield "end outer try"
    ensure:
        print "outer ensure"
        raise "Exception from outer ensure"

# NOTE: The Boojay test does not manually "close" the generator,
#       it seems that its behaviour is to close it automatically
#       when exiting a loop where it's used :-s
def consume(gen as GeneratorIterator, count as int):
    try:
        for i in range(count):
            print gen.next()
        gen.close()
    except ex:
        print "Caught: $(ex.message)"

for i in range(5):
    print "Test ${i}"
    consume(nestedEnsures(), i)
    print "====="
