namespace BooJs.Compiler.Steps

import System.IO(Path, File, Directory, StreamWriter, MemoryStream, Compression)

import Boo.Lang.Compiler.Steps(AbstractCompilerStep, ContextAnnotations)
import BooJs.Compiler.CompilerContext as JsContext
import BooJs.Compiler.CompilerParameters as JsParameters
import BooJs.Compiler.Mozilla(JsPrinter)
import BooJs.Compiler.SourceMap(MapBuilder)


class Save(AbstractCompilerStep):

    override def Run():
        if len(Errors) > 0:
            return

        ctxt = Context as JsContext
        params = Parameters as JsParameters

        fname = GetFileName()
        using writer = StreamWriter(fname):
            printer = JsPrinter(writer)
            if params.SourceMap is not null:
                printer.SourceMap = MapBuilder(
                    File: fname,
                    SourceRoot: params.SourceMapRoot
                )

            unit = ctxt.MozillaUnit
            printer.Visit(unit)

            if params.EmbedAssembly:
                writer.WriteLine()
                writer.WriteLine('//@ booAssembly=' + GetCompressedAssembly())

            if printer.SourceMap:
                mapname = params.SourceMap or GetFileName() + '.map'
                writer.WriteLine('//@ sourceMappingURL=' + Path.GetFileName(mapname))
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

            base64 = System.Convert.ToBase64String(gzipped.ToArray())

        Context.TraceVerbose('Embedding metadata assembly (binary / base64): {0} / {2}' % (len(bytes), len(base64)))

        return base64

    def GetFileName():
        fname = Parameters.OutputAssembly
        if not fname:
            fname = CompileUnit.Modules[0].Name + '.js'
        elif Directory.Exists(fname):
            fname = Path.Combine(fname, CompileUnit.Modules[0].Name + '.js')

        return Path.GetFullPath(fname)
