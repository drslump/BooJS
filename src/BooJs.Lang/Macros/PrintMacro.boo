namespace BooJs.Lang.Macros

import Boo.Lang.Compiler
import Boo.Lang.Compiler.Ast

macro print:
    log = [| BooJs.Lang.Builtins.print() |]
    log.Arguments = print.Arguments
    yield log

