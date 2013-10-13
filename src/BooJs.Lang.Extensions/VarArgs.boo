namespace BooJs.Lang.Extensions

import System

[AttributeUsage(AttributeTargets.Method | AttributeTargets.Constructor)]
class VarArgsAttribute(Attribute):
"""
    Flags a method to receive Javascript style variadic arguments.

    [VarArgs] def push(itm as object, *other as (object)):
        pass

    TODO: This should be better handled from the Extern attribute
"""
    pass

