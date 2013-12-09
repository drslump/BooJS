namespace BooJs.Lang.Macros

from System import ArgumentException
from Boo.Lang.Compiler.Ast import *
from Boo.Lang.PatternMatching import *


macro const:
""" Allows to define constants at the module level

        const FOOBAR = 'FOOBAR'
        const FOOBAR as string = 'FOOBAR'
        const FOOBAR as Error
    
"""
    case [| const $name as $type = $r |]:
        yield [|
            public static final $name as $type = $r
        |]
    case [| const $name as $type |]:
        yield [|
            public static final $name as $type
        |]
    case [| const $name = $r |]:
        yield [|
            public static final $name = $r
        |]
    otherwise:
        raise ArgumentException('Expected an assignment (ie: const foo = 10)')
