#UNSUPPORTED: Meta programming not supported yet
"""
compile time
runtime
"""
import Boo.Lang.Compiler.Ast
import Boo.Lang.Compiler.MetaProgramming

[meta]
def dict(items as (ExpressionPair)):
	print "compile time"
	h = [| {} |]
	for item in items:
		pair = [| $((item.First as ReferenceExpression).Name): $(item.Second) |]
		h.Items.Add(pair)
	return h

typeDef = [|
	class Test:
		def Run():
			print "runtime"
			return dict(A: "foo", B: "bar")
|]

type = compile(typeDef, System.Reflection.Assembly.GetExecutingAssembly())

h = (type() as duck).Run()
assert h == { "A": "foo", "B": "bar" }
