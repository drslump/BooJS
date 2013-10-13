namespace BooJs.Compiler.Steps

import Boo.Lang.Compiler.Steps(AbstractCompilerStep)

import BooJs.Compiler.CompilerContext as JsContext
import BooJs.Compiler.Mozilla(JsPrinter)


class PrintJs(AbstractCompilerStep):

    override def Run():
        return if len(Errors)

        printer = JsPrinter(OutputWriter)
        unit = Context['MozillaUnit'] #(Context as JsContext).MozillaUnit
        printer.Visit(unit)
