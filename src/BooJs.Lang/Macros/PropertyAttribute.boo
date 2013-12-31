namespace BooJs.Lang.Macros

from Boo.Lang.Compiler.Ast import *
from Boo.Lang.Extensions import PropertyAttribute as BooPropertyAttribute


class PropertyAttribute(BooPropertyAttribute):
"""
    Just defined to make it available in a global namespace for BooJs
"""

    public def constructor(propertyName as ReferenceExpression):
        super(propertyName)

    public def constructor(propertyNameAndType as TryCastExpression):
        super(propertyNameAndType)

    public def constructor(propertyName as ReferenceExpression, setPreCondition as Expression):
        super(propertyName, setPreCondition)
