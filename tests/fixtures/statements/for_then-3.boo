"""
boo
0
1
2
3
4
Did we make it?
"""

t = ("boo", "bar", "baz", "foo")

for item in t:
	print item
	for i in range(5): print i
	then: break
then:
	print "We shouldn't be here!"
	
print "Did we make it?"

/*
t = ['boo', 'bar', 'baz', 'foo'];
var $then$1 = false;
Boo.each(t, function(item){
  console.log(item);
  var $then$2 = false;
  Boo.each(Boo.range(5), function(i){ 
  	console.log(i);
  });
  if (!$then$2) $then$1 = true;
  return Boo.STOP;
});
if (!$then$1) console.log('We shouldn\'t be here!');
console.log('Did we make it?');
*/
/*
var t;
var item;
var i;

t = ['boo', 'bar', 'baz', 'foo'];
var $then$1 = false;
Boo.each(t, function(item){
  console.log(item);
  var $then$2 = false;
  Boo.each(Boo.range(5), function(i){ 
  	console.log(i);
  });
  if (!$then$2) return Boo.STOP;
});
if (!$then$1) console.log('We shouldn\'t be here!');
console.log('Did we make it?');
*/