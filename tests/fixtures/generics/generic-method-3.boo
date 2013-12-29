#UNSUPPORTED: Generics not supported yet
"""
I
Really
Hope
This
Works
"""

def Method[of T](items as (T)):
	for item in items: print item

Method[of string](("I", "Really", "Hope", "This", "Works"))
