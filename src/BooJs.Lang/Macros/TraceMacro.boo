namespace BooJs.Lang.Macros

from Boo.Lang.Compiler import CompilerContext
from Boo.Lang.Compiler.Ast import StringLiteralExpression


macro trace:
    return unless CompilerContext.Current.Parameters.Debug

    mie = [| BooJs.Lang.Builtins.print() |]
    mie.Arguments = trace.Arguments

    prefix = '{0}:{1}' % (trace.LexicalInfo.FileName, trace.LexicalInfo.Line)
    mie.Arguments.Insert(0, StringLiteralExpression(prefix))
    yield mie


