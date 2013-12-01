namespace BooJs.Compiler.Steps

from Boo.Lang.Compiler.Steps import AbstractCompilerStep

from BooJs.Compiler import CompilerContext as JsContext
from BooJs.Compiler.Mozilla import JsPrinter


class PrintJs(AbstractCompilerStep):

    override def Run():
        return if len(Errors)

        printer = JsPrinter(OutputWriter)
        unit = Context['MozillaUnit'] #(Context as JsContext).MozillaUnit
        printer.Visit(unit)
