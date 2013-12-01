namespace BooJs.Compiler.Steps

from Boo.Lang.Compiler.Steps import AbstractCompilerStep

from BooJs.Compiler import CompilerContext as JsContext
from BooJs.Compiler.Mozilla import AstPrinter


class PrintAst(AbstractCompilerStep):

    override def Run():
        return if len(Errors)

        printer = AstPrinter(OutputWriter)
        unit = Context['MozillaUnit'] #(Context as JsContext).MozillaUnit
        printer.Visit(unit)

