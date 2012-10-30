namespace BooJs.Compiler.Mozilla

import System.IO(TextWriter)
import System.Web.Script.Serialization(JavaScriptSerializer) from 'System.Web.Extensions'

import BooJs.Compiler(CompilerContext)
import BooJs.Compiler.SourceMap(MapBuilder)


class SourceMapPrinter(JsPrinter):

    [getter(SrcMap)]
    protected _srcmap as MapBuilder

    def constructor(writer as TextWriter):
        super(writer)
        _srcmap = MapBuilder()

    override def Visit(node as Node):
        if node and node.loc:
            identifier = node as Identifier
            ident = (identifier.name if identifier else null)
            pos as Position = node.loc.start
            SrcMap.Map(node.loc.source, pos.line-1, pos.column, _line, _column, ident)

        super(node)

    override def OnProgram(node as Program):
        super(node)

        # Add source map to the runtime
        if CompilerContext.Current.Parameters.Debug:
            srcmap = SrcMap.ToHash()
            Write 'Boo.sourcemap({0});', JavaScriptSerializer().Serialize(srcmap)
            #Write '//@ booSourceMap=' + JavaScriptSerializer().Serialize(srcmap)
            WriteLine
