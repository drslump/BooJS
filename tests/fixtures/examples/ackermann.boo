"""
1
125
1
125
"""

def ack1(m as int, n as int) as int:
  return (n+1 if m == 0 else ack1(m-1, (1 if n == 0 else ack1(m, n-1))))

def ack2(m as int, n as int) as int:
    return n + 1 if not m
    return ack2(m-1, 1) if not n
    return ack2(m-1, ack2(m, n-1))

#def ack(m, n):
#    return (n + 1 if m == 0 else ((ack(m-1, 1) if n == 0 else ack(m-1, ack(m, n-1)))))

print ack1(0, 0)
print ack1(3, 4)

print ack2(0, 0)
print ack2(3, 4)

