from Boo.Lang.Compiler.Ast import MethodInvocationExpression


[meta]
def @new(mie as MethodInvocationExpression):
    mie.Annotate('constructor')
    return mie