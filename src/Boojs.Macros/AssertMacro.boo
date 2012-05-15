namespace Boojs.Macros

import Boo.Lang.Compiler
import Boo.Lang.Compiler.Ast

macro assert:

    condition, = assert.Arguments
    yield [| raise Exception($(condition.ToCodeString())) if not $condition |]
