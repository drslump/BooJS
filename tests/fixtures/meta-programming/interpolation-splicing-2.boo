#UNSUPPORTED: Meta programming not supported yet
"""
print "\$(42)"
"""
foo = [| 42 |]
code = [| print "${$(foo)}" |]
print code.ToCodeString()
