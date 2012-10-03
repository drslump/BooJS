namespace BooJs.Macros

import Boo.Lang.Compiler
import Boo.Lang.Compiler.Ast


class GlobalAttribute(AbstractAstAttribute):
""" Annotate a variable declaration as a global """

    override def Apply(node as Node):
        f = node as DeclarationStatement
        if f is null:
            InvalidNodeForAttribute('DeclarationStatement')
            return
        f.Annotate('global')
