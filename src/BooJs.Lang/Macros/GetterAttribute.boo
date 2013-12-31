namespace BooJs.Lang.Macros

from Boo.Lang.Compiler.Ast import *
from Boo.Lang.Extensions import GetterAttribute as BooGetterAttribute


class GetterAttribute(BooGetterAttribute):
"""
    Just defined to make it available in a global namespace for BooJs
"""

    def constructor(propertyName as ReferenceExpression):
        super(propertyName)

    def constructor(propertyNameAndType as TryCastExpression):
        super(propertyNameAndType)


