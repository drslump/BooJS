namespace BooJs.Compiler.Steps

import Boo.Lang.Compiler.Steps(AbstractCompilerStep)

import BooJs.Compiler.CompilerContext as JsContext
import BooJs.Compiler.Mozilla(AstPrinter)


class PrintAst(AbstractCompilerStep):

    override def Run():
        return if len(Errors)

        printer = AstPrinter(OutputWriter)
        unit = (Context as JsContext).MozillaUnit
        printer.Visit(unit)

