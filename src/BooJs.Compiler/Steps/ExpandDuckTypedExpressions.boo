namespace BooJs.Compiler.Steps

from Boo.Lang.Compiler.Steps import ExpandDuckTypedExpressions as BooStep
from Boo.Lang.Compiler.TypeSystem import IType
from BooJs.Lang import RuntimeServices


class ExpandDuckTypedExpressions(BooStep):

    override def GetDuckTypingServicesType() as IType:
    """ Override the Runtime Services class
    """
        return TypeSystemServices.Map(typeof(RuntimeServices))
