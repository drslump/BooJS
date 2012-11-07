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
namespace generators

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

def consume(strings as string*, count as int):
    enumerator = strings
    try:
        for i in range(count):
            print enumerator.next()
        enumerator.close()
    except ex:
        print "Caught: ${ex.message()}"

for i in range(5):
    print "Test ${i}"
    consume(nestedEnsures(), i)
    print "====="
