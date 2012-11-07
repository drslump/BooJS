#IGNORE: Classes not supported
import System
import System.Collections

class Generators:
	
	def onetwothree():
		yield 1
		yield 2
		yield 3
	
type = Generators
method = type.GetMethod("onetwothree")
assert method is not null

returnType = method.ReturnType
assert IEnumerable in returnType.GetInterfaces()



function ontwothree () {
	var __state = 0;

	return {
		next: function() {
			switch (__state) {
			case 0:
				__state = 1;
				return 1;
			case 1:
				__state = 2;
				return 2;
			case 2:
				__state = 3;
				return 3;
			case 3:
				return Boo.STOP;
			default:
				throw new Error('Invalid generator state: ' + __state);
			}
		}
	}
}