"""

The quick brown f0x Jumped over the lazy Dog 123
"""

def trans(msg as string, rot as int):
    return msg.replace(/a-z/ig) do (m as string):
        c = m.charCodeAt(0)
        return String.fromCharCode( (c + rot + 26 - ofs) % 26 + ofs )
 
msg = "The quick brown f0x Jumped over the lazy Dog 123"
enc = trans(msg, 3)
print enc
print trans(enc, -3)
