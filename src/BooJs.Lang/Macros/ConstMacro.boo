namespace BooJs.Lang.Macros

from System import ArgumentException
from Boo.Lang.Compiler.Ast import *
from Boo.Lang.PatternMatching import *


macro const:
""" Allows to define constants at the module level

        const FOOBAR = 'FOOBAR'
"""
    case [| const $name = $r |]:
        yield [|
            public static final $name = $r
        |]
    otherwise:
        raise ArgumentException('Expected an assignment (ie: const foo = 10)')
