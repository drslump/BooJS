"""
[] True
[[] False
[]] False
[[][]] True
[[[]] False
"""

def balanced(txt):
    braced = 0
    for ch in txt:
        if ch == '[': braced += 1
        elif ch == ']': braced -= 1
        return false if braced < 0
    return braced == 0

for s in ('[]', '[[]', '[]]', '[[][]]', '[[[]]'):
    print s, balanced(s)