import Boo.Lang.Compiler.Ast


[meta]
def @new(mie as MethodInvocationExpression):
    mie.Annotate('constructor')
    return mie