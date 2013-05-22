namespace BooJs.Compiler

import Boo.Lang.Compiler.TypeSystem.Reflection
import Boo.Lang.Compiler.CompilerParameters as BooCompilerParameters

import System.Reflection(Assembly)
import System.IO(File, StreamReader, MemoryStream, Compression)
import System(Convert)

class CompilerParameters(BooCompilerParameters):

    [Property(EmbedAssembly)]
    _embedasm = true

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
                m = /^\s*\/\/@\s*booAssembly\s*=\s*([^\s]+)/.Match(sr.ReadLine())
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

    private def TraceMessage(msg as string):
        if TraceInfo:
            System.Console.Out.WriteLine(msg);        

    override def ForName(assembly as string, throwOnError as bool) as Assembly:

        # Try to load the assembly using Boo's default mechanism
        try:
            return super(assembly, true)
        except ex as System.ApplicationException:
            # Build a list of possible directories where the assembly name
            # could be. The algorithm starts checking dirs separated by dots
            # and generates variants with sub directories.
            # ie: foo.bar.baz, foo.bar/baz, foo/bar/baz
            paths = []
            parts = assembly.Split(char('.'))
            for i in range(len(parts), 0):
                paths.Add(
                    System.IO.Path.Combine(
                        join(parts[:i], '.'),
                        System.IO.Path.Combine(*parts[i:])
                    )
                )

            TraceLevel = System.Diagnostics.TraceLevel.Info

            self.LibPaths.Insert(0, '/Users/drslump/tmp/imports')
            for libpath in self.LibPaths:
                TraceMessage("Looking for namespace $assembly in '$libpath'")
                for dirpath in paths:
                    path = System.IO.Path.Combine(libpath, dirpath)
                    if System.IO.Directory.Exists(path):
                        # Collect source files
                        files = []
                        for fname in System.IO.Directory.GetFiles(path, '*.boo'):
                            continue unless fname.EndsWith('boo')
                            files.Add(fname)

                        # The directory needs to contain at least one file
                        continue if not len(files)

                        TraceMessage("Mapping namespace $assembly to '$path'")

                        # Check if there is a previously compiled version
                        if System.IO.File.Exists(path + '.booc'):
                            TraceMessage("Trying to use cached compilation from '$path.booc'")
                            asm = Assembly.Load(
                                System.IO.File.ReadAllBytes(path + '.booc')
                            )
                            attrs = asm.GetCustomAttributes(typeof(SourceTimestampAttribute), true)
                            valid = true
                            for attr as SourceTimestampAttribute in attrs:
                                if attr.FileName not in files:
                                    TraceMessage("Ignoring cache. File $(attr.FileName) was removed")
                                    valid = false
                                    break
                                
                                if attr.TimeStamp != System.IO.File.GetLastWriteTimeUtc(attr.FileName).ToFileTimeUtc():
                                    TraceMessage("Ignoring cache. File $(attr.FileName) was modified")
                                    valid = false
                                    break

                                files = [f for f in files if f != attr.FileName]

                            if valid:
                                if len(files):
                                    TraceMessage("Ignoring cache. File $(files[0]) was added")
                                else:
                                    TraceMessage("Cached compilation at '$path.booc' is up to date")
                                    return asm

                            # Remove file if possible so we clean up as we go
                            try:
                                System.IO.File.Delete(path + '.booc')
                            except:
                                pass

                        # Create new compiler based on the current configuration
                        comp = BooJs.Compiler.newBooJsCompiler(BooJs.Compiler.Pipelines.CompileToMemory())
                        #comp = Boo.Lang.Compiler.BooCompiler()
                        #comp.Parameters.Pipeline = Boo.Lang.Compiler.Pipelines.CompileToMemory()

                        comp.Parameters.Strict = self.Strict
                        comp.Parameters.Debug = self.Debug
                        comp.Parameters.References = self.References
                        comp.Parameters.OutputAssembly = '/tmp/auto.dll'

                        for fname in files:
                            comp.Parameters.Input.Add(Boo.Lang.Compiler.IO.FileInput(fname))

                        context = comp.Run()
                        for war in context.Warnings:
                            Boo.Lang.Compiler.CompilerContext.Current.Warnings.Add(war)
                            #print war
                        for err in context.Errors:
                            print err.LexicalInfo.FileName
                            Boo.Lang.Compiler.CompilerContext.Current.Errors.Add(err)
                            #print err

                        if len(context.Errors):
                            asmb = System.AppDomain.CurrentDomain.DefineDynamicAssembly(
                                System.Reflection.AssemblyName('ImportError'),
                                System.Reflection.Emit.AssemblyBuilderAccess.Run
                            )
                            return asmb

                        if not len(context.Errors):
                            asmb = context.GeneratedAssembly as System.Reflection.Emit.AssemblyBuilder

                            for mod in context.CompileUnit.Modules:
                                dt = System.IO.File.GetLastWriteTimeUtc(mod.LexicalInfo.FullPath)
                                #print mod.LexicalInfo.FullPath

                                attrCtor = typeof(SourceTimestampAttribute).GetConstructor(
                                    (typeof(string), typeof(long))
                                )
                                attr = System.Reflection.Emit.CustomAttributeBuilder(
                                    attrCtor, (mod.LexicalInfo.FullPath, dt.ToFileTimeUtc())
                                )

                                asmb.SetCustomAttribute(attr)

                            asmb.Save('auto.dll')

                            try:
                                System.IO.File.Copy('/tmp/auto.dll', path + '.booc', true)
                                TraceMessage("Caching compilation into '$path.booc'")
                            except:
                                pass

                            return asmb

            if assembly[-3:] == '.js' and File.Exists(assembly):
                try:
                    asm = ExtractAssembly(assembly)
                    return asm if asm
                except ex:
                    if throwOnError: raise ex

            raise



class SourceTimestampAttribute(System.Attribute):

    property FileName as string
    property TimeStamp as long

    def constructor(fname as string, timestamp as long):
        FileName = fname
        TimeStamp = timestamp

