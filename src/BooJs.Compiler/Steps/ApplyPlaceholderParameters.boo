namespace BooJs.Compiler.Steps

from Boo.Lang.Compiler.Ast import *
from Boo.Lang.Compiler.Steps import AbstractFastVisitorCompilerStep


class ApplyPlaceholderParameters(AbstractFastVisitorCompilerStep):
"""
    Like in Scala, underscores in anonymous functions (block expressions) are
    mapped to positional arguments.

        map data, { _ + _ * 2 }
        map data, { arg1 as duck, arg2 as duck | arg1 + arg2 * 2 }
"""
    _blocks = List[of BlockExpression]()

    Block as BlockExpression:
        get: return (_blocks[-1] if len(_blocks) else null)

    public def Run():
        if len(Errors) > 0:
            return

        _blocks.Clear()
        Visit(CompileUnit)

    override def OnBlockExpression(node as BlockExpression):
        _blocks.Add(node)
        super(node)
        _blocks.Pop()

    override def OnReferenceExpression(node as ReferenceExpression):
        if node.Name == '_' and Block:
            node.Name = Context.GetUniqueName('arg')
            decl = ParameterDeclaration(Name: node.Name, Type: SimpleTypeReference('duck'))
            Block.Parameters.Add(decl)
