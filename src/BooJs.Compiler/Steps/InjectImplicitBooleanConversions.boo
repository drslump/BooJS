namespace BooJs.Compiler.Steps

import Boo.Lang.Compiler.Ast
import Boo.Lang.Compiler.Steps

class InjectImplicitBooleanConversions(AbstractTransformerCompilerStep):

    def AssertBoolContext(expression as Expression):
    """ Override the conversion of bool values. In JS we just assume any type can be
        coerced into a boolean expression
    """
        return expression
