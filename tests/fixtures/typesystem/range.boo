"""
0 1 2
continue 2
break 0
return 11
"""

import BooJs.Lang.Async(AsyncAttribute, async, AwaitMacro)
import BooJs.Lang.Api(jQuery)


const foobar = 'foo'

# Either as an attribute, a macro or a simple function
[async] def foo(limit):
	print 'start'
	try:
		print 'Fetching resource...'
		await data = jQuery.get('tester.html')
		print 'DATA:', data
		#await a, b, c = 'two', 'foo', 'bar'   # automatically wraps in a `when`

		/*
		await data = $.ajax(url)
		$('#result').html(data)
	    status = $('#status').html('Download complete.')
	    await status.fadeIn().promise()
	    await: sleep(2000)
	    status.fadeOut()
	    */
	except:
		print 'Error downloading!'

	print "end"

/*
bar = async do():
	await data = jQuery.get('http://pollinimini.net')
	print data
*/

#for itm in foo():
#	print 'ITEM:', itm
/*
iterator = foo()
print 'NEXT: ', iterator.next()
iterator.send('FOO')
*/




/*
#def foo(items as Array):
def foo(items as int*):
	print items

a1 = [1,2,3]
a2 = (1,2,3)
a3 = Array()
a3.push(1)
a3.push(2)
a3.push(3)
a4 = Array[of string]()
a4.push('1')
a4.push('2')
a4.push('3')
a5 = range(3)
a6 = xrange(3)

foo( a1 )
foo( a2 )
foo( a3 )
foo( a4 )
foo( a5 )
foo( a6 )


def loop_with_return():
	for i in range(3):
		return i if i > 0

res = []
for i in range(3):
	res.push(i)

print join(res, ' ')

for i in range(3):
	if i < 2: continue
	print 'continue', i

for i in range(3):
	if i > 0: break
	print 'break', i

print 'return', loop_with_return() + 10
*/
