#IGNORE: Classes not supported
import System

callable Function(item) as object

callable StringFunction(item as string) as string

class Handler:
	[property(Prefix)]
	_prefix = null
	
	def Handle(value):
		return "${_prefix} - ${value}"

fn = cast(StringFunction, cast(Function, Handler(Prefix: "Function").Handle))
assert "Function - 14" == fn("14")
