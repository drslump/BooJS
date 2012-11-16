"""
0, 1, 2, 3, 4, 5, 6, 7, 8, 9
"""
def heapsort(lst as (int)) as (int):
""" Heapsort. Note: this function sorts in-place (it mutates the list). """
 
  # in pseudo-code, heapify only called once, so inline it here
  for start in range((len(lst)-2)/2, -1, -1):
    siftdown(lst, start, len(lst)-1)
 
  for end in range(len(lst)-1, 0, -1):
    #lst[end], lst[0] = lst[0], lst[end]
    t = lst[end]
    lst[end] = lst[0]
    lst[0] = t
    siftdown(lst, 0, end - 1)
    
  return lst
 
def siftdown(lst as (int), start as int, end as int):
  root = start
  while true:
    child = root * 2 + 1
    if child > end: break
    if child + 1 <= end and lst[child] < lst[child + 1]:
      child += 1
    if lst[root] < lst[child]:
      #lst[root], lst[child] = lst[child], lst[root]
      t = lst[root]
      lst[root] = lst[child]
      lst[child] = t
      root = child
    else:
      break

lst = [7, 6, 5, 9, 8, 4, 3, 1, 2, 0]
print join(heapsort(lst), ', ')
