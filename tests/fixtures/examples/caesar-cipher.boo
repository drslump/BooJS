"""
The quick brown f0x Jumped over the lazy Dog 123
The quick brown f0x Jumped over the lazy Dog 123
"""
def trans(msg as string, rot as int):
    return msg.replace(/a-z/ig) do (m as string):
        c = m.charCodeAt(0)
        return String.fromCharCode( (c + rot + 26) % 26 )
 
msg = "The quick brown f0x Jumped over the lazy Dog 123"
enc = trans(msg, 3)
print enc
print trans(enc, -3)
