foo as duck

#a = foo?.bar

b = foo?.bar?.baz
# (foo ? (foo.bar) : null) ? (foo.bar.baz) : null;

#print foo?.bar
