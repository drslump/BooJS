"""
42
"""
def bar(fn as callable):
	return fn()

def foo():
	return bar: // dsl friendly invocation syntax
		return 42
		
def baz():
	a = bar:
		return 42

print foo()

# doc = XmlBuilder()
# doc.html:
# 	doc.body:
# 		doc.text("Hello, world!")
