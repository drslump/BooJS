"""
3628800
"""
def fatorial(n as int) as int:	
	return n * fatorial(n-1) if n > 1
	return 1

print fatorial(10)

