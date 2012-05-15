namespace Boojs.Macros

import Boo.Lang.Compiler
import Boo.Lang.Compiler.Ast

macro print:
    # TODO: When using a runtime use it instead of accessing console
    return

    if 0 == len(print.Arguments):
        yield [| java.lang.System.out.print('') |]
        return

    #yield [| global().console.log.apply(console, print.Arguments) |]
        
    last = print.Arguments[-1]
    for arg in print.Arguments:
        if arg is last: break
        yield [| java.lang.System.out.print($arg) |]
        yield [| java.lang.System.out.print(' ') |]
        
    yield [| java.lang.System.out.println($last) |]


# TODO: Doesn't work :(
macro require:
    name = require.Arguments[0]
    yield [| $name as global |]

