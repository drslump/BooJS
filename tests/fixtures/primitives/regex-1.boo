s = "OK\nfoo\nbar"

# NOTE: In .Net the test method is called `match`
assert false == /ok/.test(s)
assert false == /ok/g.test(s)

assert true == /ok/i.test(s)
assert true == /^ok/i.test(s)

assert false == /^foo/.test(s)
assert true == /^foo/m.test(s)

assert false == /^FOO/.test(s)
assert true == /^FOO/mi.test(s)

assert false == /foo.bar/.test(s)
assert true == /foo.bar/s.test(s)
