namespace BooJs.Compiler.Steps

from System import Convert
from System.Text import Encoding
from System.IO import Path, File, Directory, StreamWriter, MemoryStream, Compression

from Boo.Lang.Compiler.Steps import AbstractCompilerStep, ContextAnnotations
from BooJs.Compiler import CompilerContext as JsContext, CompilerParameters as JsParameters
from BooJs.Compiler.Mozilla import JsPrinter
from BooJs.Compiler.SourceMap import MapBuilder


class Save(AbstractCompilerStep):

    override def Run():
        if len(Errors) > 0:
            return

        ctxt = Context as JsContext
        params = Parameters as JsParameters

        fname = GetFileName()
        using writer = StreamWriter(fname):
            printer = JsPrinter(writer)
            printer.Debug = params.Debug

            if params.SourceMap is not null:
                printer.SourceMap = MapBuilder(
                    File: fname,
                    SourceRoot: params.SourceMapRoot
                )

            unit = ctxt['MozillaUnit']
            printer.Visit(unit)

            if params.EmbedAssembly:
                writer.WriteLine()
                writer.WriteLine('//# booAssembly=' + GetCompressedAssembly())

            if printer.SourceMap:
                # Dump it inline
                if params.SourceMap == '-':
                    uri = 'data:application/json;charset=utf-8;base64,' + Convert.ToBase64String(
                        Encoding.UTF8.GetBytes(printer.SourceMap.ToJSON())
                    )
                    writer.WriteLine('//# sourceMappingURL=' + uri)
                else:
                    mapname = params.SourceMap or GetFileName() + '.map'
                    writer.WriteLine('//# sourceMappingURL=' + Path.GetFileName(mapname))
                    File.WriteAllText(mapname, printer.SourceMap.ToJSON())

        # Finally set the generated filename in the context
        ctxt.GeneratedAssemblyFileName = fname

    def GetCompressedAssembly():
        fname = Path.GetFileName(Context.GeneratedAssemblyFileName)
        builder = ContextAnnotations.GetAssemblyBuilder(Context)
        builder.Save(fname)

        using gzipped = MemoryStream():
            using gzip = Compression.GZipStream(gzipped, Compression.CompressionMode.Compress, true):
                bytes = File.ReadAllBytes(Context.GeneratedAssemblyFileName)
                gzip.Write(bytes, 0, len(bytes))

            base64 = Convert.ToBase64String(gzipped.ToArray())

        Context.TraceVerbose('Embedding metadata assembly (binary / base64): {0} / {2}' % (len(bytes), len(base64)))

        return base64

    def GetFileName():
        fname = Parameters.OutputAssembly
        if not fname:
            fname = CompileUnit.Modules[0].Name + '.js'
        elif Directory.Exists(fname):
            fname = Path.Combine(fname, CompileUnit.Modules[0].Name + '.js')

        return Path.GetFullPath(fname)
