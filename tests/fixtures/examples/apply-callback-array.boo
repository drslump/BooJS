"""
list comprehension: 1,9,25,49
functional: 1,9,25,49
with expression: 1,9,25,49
without callback: 1,9,25,49
"""
 
def square(n as int):
    return n * n
 
numbers = [1, 3, 5, 7]
print 'list comprehension:', (square(n) for n in numbers) 
print 'functional:', map(numbers, square)      
print 'with expression:', map(numbers, {x as int| x*x})
print 'without callback:', (n * n for n as int in numbers)      
