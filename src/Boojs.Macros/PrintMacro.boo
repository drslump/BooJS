namespace Boojs.Macros

import Boo.Lang.Compiler
import Boo.Lang.Compiler.Ast

macro print:
    # TODO: When using a runtime use it instead of accessing console directly
    # TODO: Find out an strategy to support an arbitrary number of args

    l = len(print.Arguments)
    if 0 == l:
        yield [| global.console.log('') |]
    elif 1 == l:
        arg = print.Arguments[0]
        yield [| global.console.log($arg) |]
    elif 2 == l:
        arg1 = print.Arguments[0]
        arg2 = print.Arguments[1]
        yield [| global.console.log($arg1, $arg2) |]
    elif 3 == l:
        arg1 = print.Arguments[0]
        arg2 = print.Arguments[1]
        arg3 = print.Arguments[2]
        yield [| global.console.log($arg1, $arg2, $arg3) |]

    return

# TODO: Doesn't work :(
macro require:
    name = require.Arguments[0]
    yield [| $name as global |]

