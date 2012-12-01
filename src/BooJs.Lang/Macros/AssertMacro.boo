namespace BooJs.Lang.Macros

import Boo.Lang.Compiler
import Boo.Lang.Compiler.Ast

macro assert:
    cond, = assert.Arguments
    message = cond.ToCodeString()
    yield [| raise BooJs.Lang.Builtins.AssertionError($message) if not $cond |]
