namespace BooJs.Compiler.Steps

from Boo.Lang.Compiler.Steps import AbstractFastVisitorCompilerStep
# import BooJs.Compiler.CompilerContext as JsCompilerContext
from BooJs.Compiler.Visitors import MozillaAstVisitor


class MozillaAst(AbstractFastVisitorCompilerStep):
"""
Transforms the Boo AST into a Mozilla AST
"""
    _visitor = MozillaAstVisitor()

    override def Run():
        return if len(Errors)

        # Transform the Boo AST into a Mozilla AST
        # cntx = Context as JsCompilerContext
        # cntx.MozillaUnit = _visitor.Run(CompileUnit)
        Context['MozillaUnit'] = _visitor.Run(CompileUnit)
