#UNSUPPORTED: Meta programming not supported yet
"""
public bar as string
"""
fieldInitializer as Boo.Lang.Compiler.Ast.Expression
field = [|
	public bar as string = $fieldInitializer
|]
print field.ToCodeString()



