namespace BooJs.Compiler.Steps

import System
import Boo.Lang.Compiler.Ast
import Boo.Lang.Compiler.Steps.ExpandDuckTypedExpressions as BooStep
import Boo.Lang.Compiler.TypeSystem
import BooJs.Lang.Runtime.Services as RuntimeServices

class ExpandDuckTypedExpressions(BooStep):

    override def GetDuckTypingServicesType() as IType:
        return TypeSystemServices.Map(typeof(RuntimeServices))
