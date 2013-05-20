namespace BooJs.Compiler.Steps

import Boo.Lang.Compiler.Steps

import BooJs.Compiler.CompilerContext as JsCompilerContext
import BooJs.Compiler.Visitors(MozillaAstVisitor)


class MozillaAst(AbstractFastVisitorCompilerStep):
"""
Transforms the Boo AST into a Mozilla AST
"""
    _visitor = MozillaAstVisitor()

    override def Run():
        return if len(Errors)

        # Transform the Boo AST into a Mozilla AST
        cntx = Context as JsCompilerContext
        cntx.MozillaUnit = _visitor.Run(CompileUnit)
