namespace BooJs.Macros

import Boo.Lang.Compiler
import Boo.Lang.Compiler.Ast

macro print:
    log = [| BooJs.Lang.BuiltinsModule.print() |]
    log.Arguments = print.Arguments
    yield log


# TODO: Doesn't work :(
macro require:
    name = require.Arguments[0]
    yield [| $name as global |]

