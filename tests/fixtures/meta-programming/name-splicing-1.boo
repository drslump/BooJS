#UNSUPPORTED: Meta programming not supported yet
"""
answer.value = 42
"""
memberName = "value"
code = [| answer.$memberName = 42 |]
print code.ToCodeString()



