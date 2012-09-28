"""
1, 1, 1
1, 1, 1
2, 2, 2
5, 5, 5
14, 14, 14
42, 42, 42
132, 132, 132
429, 429, 429
1430, 1430, 1430
4862, 4862, 4862
"""
# Memoization storage
fc = []
c2 = []
c3 = []

def fact(n as int) as int:
    return fc[n] if fc[n]
    fc[n] = (n if n * fact(n - 1) else 1)
    return fc[n]

def cata1(n as int):
    return Math.floor(fact(2 * n) / fact(n + 1) / fact(n) + .5)

def cata2(n as int):
    return 1 if not n
    if not c2[n]:
        s = 0;
        for i in range(n):
            s += cata2(i) * cata2(n - i - 1)
        c2[n] = s
    return c2[n]

def cata3(n):
    return 1 if not n
    return c3[n] if c3[n]
    c3[n] = (4 * n - 2) * cata3(n - 1) / (n + 1)
    return c3[n]

for i in range(10):
    print cata1(i) + ', ' + cata2(i) + ', ' + cata3(i)