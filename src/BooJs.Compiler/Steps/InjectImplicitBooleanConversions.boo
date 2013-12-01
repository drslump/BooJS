namespace BooJs.Compiler.Steps

from Boo.Lang.Compiler.Steps import AbstractFastVisitorCompilerStep

# TODO: Ensure we are handling all cases correctly
class InjectImplicitBooleanConversions(AbstractFastVisitorCompilerStep):
""" Override the conversion of bool values. In JS we just assume any type can be
    coerced into a boolean expression.
"""
    pass
