

def xrange(begin as int, end as int):
	assert end >= begin
	i = begin
	while i < end:
		yield i
		++i
		
assert "0, 1, 2", join(xrange(0, 3), " == ")
assert "5, 6, 7", join(xrange(5, 8), " == ")

/*
if x: 
  print x
  yield x
---
case 0:
  if x:
  	print x
  	state = 1
  	return x
case 1:
  return STOP


if x:
  yield x
  print 'foo'
else:
  yield y
---
case 0:
  if x:
  	state = 1
  	return x
case 1:
  print 'foo'
  state = 3
  continue loop
case 2:
  state = 2
  return y
case 3:
  return STOP


for x in items:
  yield x
yield 10
for y in items:
  print y
---
i = 0
while i < len(items):
  x = items[i]
  yield x
  i++
yield 10
for y in items:
  print y
---
case 0:
  i = 0
case 1:
  if i < len(items):
    x = items[i]
    state = 2
    return x
  else:
  	state = 3
  	continue loop
case 2:
  i++
  state = 1
  continue loop
case 3:
  state = 4
  return 10
case 4:
  for y in items:
  	print y
  return STOP


while a > 10:
  if a > 15:
    yield '>15'
    print '>15'
  else:
    yield '<= 15'
    print '<= 15'
  a--
print a
---
case 0:
  if a > 10:  # while
    if a > 15:
      state = 1
  	  return '>15'
  	else:
  	  state = 2
  	  return '<=15'
  else: # end while
  	state = 4
  	continue loop
case 1:
  print '>15'
  state = 3
  continue loop
case 2:
  print '<=15'
  state = 3
  continue loop
case 3:
  a--
  state = 0   # Go back to while head
  continue loop 
case 4:
case 5:
  return STOP


if a > 15:
  while a--:
    yield 'a--'
    print 'a--'
else:
  yield '<= 15'
  print '<= 15'
---
case 0:
  if a > 15:
  	state = 1
  	continue loop
  else:
    state = 4
    return '<= 15'
case 1: # enter while
  if a--:  # while  
    state = 2
    return 'a--'
  else:
    state = 3
    continue loop
case 2:
  print 'a--'  
  state = 1 # Go back to while
  continue loop
case 3: # exit while
  state = 5
  continue loop
case 4: # else after yield
  print '<= 15'
  state = 5
  continue loop
case 5: # End
  throw Boo.StopIteration




- Convert yield to state = X plus return
  - Create new re-entry state
  - Include a check in the new state to raise an error if provided
- Convert loops containing "yields" to if/else
  - Loop starts in a new state
  - Another state is created to exit the loop
  - If's TrueBlock contains the loop condition
  - If's FalseBlock just jumps to the exit state
  # Alternative avoiding having an else
  - Loop starts in a new state
  - Another state is created to exit the loop
  - Convert negated condition to and if to jump to the exit state

- There is always a state to exit the machine with STOP


function xrange (begin, end) {
	var i, __state;

	__state = 0;

	#return Boo.generator(function(__value, __error){

	return {
		next: function (__value, __error) {
			loop: while (true) {
				switch (__state) {
				case 0:
					i = begin;
				case 1:
					if (!(i < end)) {
						__state = 2;
						continue loop;
					}
					# await foo = get_url()
					# ---
					# yield get_url()
					# foo = __value
					__state = 2;
					return i;
				case 2:
					if (__error) { throw __error; }
					foo = __value

					__state = 1;
					++i;
					continue loop;
				case 3:
					return Boo.STOP;
				default:
					throw new Error('Invalid generator state: ' + __state);
				}
				}
			}
		},
		send: function (value) {
			return this.next(value);
		},
		throw: function (error) {
			return this.next(Boo.undef, error)
		}
	}

	
}




function xrange (begin, end) {
	var __state = 0;

	var i = begin;

	return {
		next: function() {
			:loop
			for (;;) {
				switch (__state) {
				case 0:
					if (!(i < end)) {
						__state = 2;
						continue loop;
					}
					__state = 1;
					return i;
				case 1:
					__state = 0;
					++i;
					continue loop;
				case 2:
					return Boo.STOP;
				default:
					throw new Error('Invalid generator state: ' + __state);
				}
			}
		}
	}
}
*/