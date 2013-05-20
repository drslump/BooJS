namespace BooJs.Compiler.Steps

import System
import Boo.Lang.Compiler.Steps.ExpandDuckTypedExpressions as BooStep
import Boo.Lang.Compiler.TypeSystem
import BooJs.Lang(RuntimeServices)


class ExpandDuckTypedExpressions(BooStep):

    override def GetDuckTypingServicesType() as IType:
    """ Override the Runtime Services class
    """
        return TypeSystemServices.Map(typeof(RuntimeServices))
