class Test:

	static def IsNotNull(o):
		return o != null
		
	static def IsNull(o):
		return o == null

assert Test.IsNotNull({}) == true
assert Test.IsNotNull(null) == false
assert Test.IsNotNull('') == true
assert Test.IsNull({}) == false
assert Test.IsNull(null) == true
assert Test.IsNull('') == false
