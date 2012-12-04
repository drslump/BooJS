namespace BooJs.Lang.Macros

import Boo.Lang.Compiler
import Boo.Lang.Compiler.Ast

macro assert:
    return unless CompilerContext.Current.Parameters.Debug
    cond, = assert.Arguments
    message = cond.ToCodeString()
    yield [| raise BooJs.Lang.Builtins.AssertionError($message) if not $cond |]
