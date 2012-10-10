"""
, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55
"""
def fibo(n as int) as int:
    # We need to declare it before it can be used inside the closure
    fn as callable(int) as int = null
    fn = {n as int| return (1 if n < 2 else fn(n-1) + fn(n-2)) }
    return (null if n < 0 else fn(n))

print join(fibo(i) for i in range(-1, 10), ', ')

#Y = lambda f: (lambda x: x(x))(lambda y: f(lambda *args: y(y)(*args)))
#>>> fib = lambda f: lambda n: None if n < 0 else (0 if n == 0 else (1 if n == 1 else f(n-1) + f(n-2)))