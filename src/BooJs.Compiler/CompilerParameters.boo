namespace BooJs.Compiler

from Boo.Lang.Compiler.TypeSystem.Reflection import *
from Boo.Lang.Compiler import CompilerParameters as BooCompilerParameters

from System.Reflection import Assembly
from System.IO import File, StreamReader, MemoryStream, Compression
from System import Convert


class CompilerParameters(BooCompilerParameters):

    [Property(EmbedTypes)]
    _embedtypes = true

    [Property(SourceMap)]
    _sourceMap = null

    [Property(SourceMapRoot)]
    _sourceMapRoot = null


    def constructor():
        super(true)

    def constructor(loadDefault as bool):
        super(BooCompilerParameters.SharedTypeSystemProvider, loadDefault)

    def constructor(provider as IReflectionTypeSystemProvider):
        super(provider)

    def constructor(provider as IReflectionTypeSystemProvider, loadDefaultReferences as bool):
        super(provider, loadDefaultReferences)

    protected def ExtractAssembly(fname as string) as Assembly:
    """ Inspect a javascript file looking for an embedded assembly
    """
        asm = null
        using sr = StreamReader(fname):
            while sr.Peek() >= 0:
                m = /^\s*\/\/[@#]\s*booAssembly\s*=\s*([^\s]+)/.Match(sr.ReadLine())
                if m.Success:
                    asm = DecompressAssembly(m.Groups[1].Value)
                    break

        return asm

    protected def DecompressAssembly(base64 as string) as Assembly:
        BUFFER_SIZE = 4096
        buffer = array(byte, BUFFER_SIZE)

        gzipped = Convert.FromBase64String(base64)
        using input = MemoryStream(gzipped), \
              output = MemoryStream(), \
              gzip = Compression.GZipStream(input, Compression.CompressionMode.Decompress, true):

            while true:
                consumed = gzip.Read(buffer, 0, BUFFER_SIZE)
                output.Write(buffer, 0, consumed)
                break if consumed < BUFFER_SIZE

        return Assembly.Load(output.ToArray())

    override def ForName(assembly as string, throwOnError as bool) as Assembly:
        if assembly[-3:] == '.js' and File.Exists(assembly):
            try:
                asm = ExtractAssembly(assembly)
                return asm if asm
            except ex:
                if throwOnError: raise ex

        return super(assembly, throwOnError)
