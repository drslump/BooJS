s = "OK\nfoo\nbar"

assert false == /ok/.match(s)
assert false == /ok/g.match(s)

assert true == /ok/i.match(s)
assert true == /^ok/i.match(s)

assert false == /^foo/.match(s)
assert true == /^foo/m.match(s)

assert false == /^FOO/.match(s)
assert true == /^FOO/mi.match(s)

assert false == /foo.bar/.match(s)
assert true == /foo.bar/s.match(s)
