namespace BooJs.Compiler.Steps

import Boo.Lang.Compiler.Steps

# TODO: Ensure we are handling all cases correctly
class InjectImplicitBooleanConversions(AbstractTransformerCompilerStep):
""" Override the conversion of bool values. In JS we just assume any type can be
    coerced into a boolean expression
"""
    pass
