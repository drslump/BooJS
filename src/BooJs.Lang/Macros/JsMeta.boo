from Boo.Lang.Compiler.Ast import Expression


[meta]
def js(exp as Expression):
    exp = [| BooJs.Lang.Globals.eval($exp) |]
    exp.Annotate('verbatim')
    return exp