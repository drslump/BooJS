"""
@IGNORE@
"""
import Boo.Lang.Environments

objectBinding = object()
stringBinding = "42"

executed = false
ActiveEnvironment.With(ClosedEnvironment(objectBinding, stringBinding)):
	assert my(object) is objectBinding
	assert my(string) is stringBinding
	executed = true
	
assert executed
