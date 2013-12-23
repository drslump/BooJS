"""
0
1
"""
enum E:
  E0
  E1

def ps(s as double):
  print s.toString()

ps E.E0 cast double
ps E.E1 cast double
