namespace BooJs.Lang.Macros

import Boo.Lang.Compiler(CompilerContext)
import Boo.Lang.Compiler.Ast(StringLiteralExpression)


macro trace:
    return unless CompilerContext.Current.Parameters.Debug

    mie = [| BooJs.Lang.Builtins.print() |]
    mie.Arguments = trace.Arguments

    prefix = '{0}:{1}' % (trace.LexicalInfo.FileName, trace.LexicalInfo.Line)
    mie.Arguments.Insert(0, StringLiteralExpression(prefix))
    yield mie


