namespace BooJs.Lang.Macros

import Boo.Lang.Compiler.Ast
import Boo.Lang.PatternMatching


macro const:
""" Allows to define constants at the module level

        const FOOBAR = 'FOOBAR'
"""
    case [| const $name = $r |]:
        yield [|
            public static final $name = $r
        |]
    otherwise:
        raise System.ArgumentException('Expected an assignment (ie: const foo = 10)')
