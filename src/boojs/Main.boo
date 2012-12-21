namespace boojs

import System
import System.Reflection
import System.Diagnostics(Trace, TraceLevel, TextWriterTraceListener)
import System.IO as SysIO
import Boo.Lang.Compiler
import Boo.Lang.Compiler.IO
import BooJs.Compiler
import BooJs.Compiler.CompilerParameters as JsCompilerParameters
import BooJs.Compiler.CompilerContext as JsCompilerContext

import Boo.Ide


def loadAssembly(name as string):
    if SysIO.File.Exists(name):
        return Assembly.LoadFrom(name)
    return Assembly.Load(name)

def parseCommandLine(argv as (string)):
    try:
        cmdLine = CommandLine(argv)
        if (not cmdLine.IsValid) or cmdLine.DoHelp:
            cmdLine.PrintOptions()
            return null
        return cmdLine
    except x:
        print "BCE000: ", x.Message
        return null

def selectPipeline(cmdLine as CommandLine):
    return Pipelines.SaveJs()
    
def configureParams(cmdLine as CommandLine, params as JsCompilerParameters):
    params.Debug = cmdLine.Debug
    params.OutputAssembly = getOutputDirectory(cmdLine)
    params.Ducky = cmdLine.Ducky
    params.EmbedAssembly = cmdLine.EmbedAssembly
    params.SourceMap = cmdLine.SourceMap
    params.SourceMapRoot = cmdLine.SourceMapRoot

    if cmdLine.Verbose:
        params.TraceLevel = TraceLevel.Verbose
        Trace.Listeners.Add(TextWriterTraceListener(System.Console.Error))

    for refe in cmdLine.References:
        params.LoadAssembly(refe)

    for fname in cmdLine.SourceFiles():
        params.Input.Add(FileInput(fname))

def showErrorsWarnings(cmdLine as CommandLine, result as JsCompilerContext):
    for warning in result.Warnings:
        System.Console.Error.WriteLine( warning )
    for error in result.Errors:
        System.Console.Error.WriteLine( error.ToString(cmdLine.Verbose) )
    
def getOutputDirectory(cmdLine as CommandLine):
    return cmdLine.OutputDirectory




cmdLine = parseCommandLine(argv)
if cmdLine is null: return

if cmdLine.HintMembers:
    index = ProjectIndex()
    for refe in cmdLine.References:
        index.AddReference(refe)

    sources = array(cmdLine.SourceFiles())
    if len(sources) > 1:
        raise 'Only one source file is supported in hints mode'

    source = sources[0]
    parts = source.Split(char('@'))
    filename = parts[0]
    ofs as int
    int.TryParse(parts[1], ofs)
    code = SysIO.File.ReadAllText(filename)

    code = code.Substring(0, ofs) + '__cursor__' + code.Substring(ofs)
    print code

    items = index.ProposalsFor(filename, code)
    for itm in items:
        #hints[ itm.Name ] = itm.Description
        print '{0}: {1}' % (itm.Name, itm.Description)

    return

if cmdLine.HintLocals:
    index = ProjectIndex()
    for refe in cmdLine.References:
        index.AddReference(refe)

    sources = array(cmdLine.SourceFiles())
    if len(sources) > 1:
        raise 'Only one source file is supported in hints mode'

    source = sources[0]
    parts = source.Split(char('@'))
    filename = parts[0]
    line as int
    int.TryParse(parts[1], line)
    code = SysIO.File.ReadAllText(filename)

    locals = index.LocalsAt(filename, code, line)
    for itm in locals:
        print itm

    return

if cmdLine.HintOverloads:
    index = ProjectIndex()
    for refe in cmdLine.References:
        index.AddReference(refe)

    sources = array(cmdLine.SourceFiles())
    if len(sources) > 1:
        raise 'Only one source file is supported in hints mode'

    source = sources[0]
    parts = source.Split(char('@'))
    filename = parts[0]
    lline as int
    int.TryParse(parts[1], lline)
    code = SysIO.File.ReadAllText(filename)

    methods = index.MethodsFor(filename, code, cmdLine.HintOverloads, lline)
    for method in methods:
        print '{0}({1}) as {2}' % (method.Name, join(method.Arguments, ', '), method.ReturnType)

    return

if cmdLine.HintTarget:
    index = ProjectIndex()
    for refe in cmdLine.References:
        index.AddReference(refe)

    sources = array(cmdLine.SourceFiles())
    if len(sources) > 1:
        raise 'Only one source file is supported in hints mode'

    source = sources[0]
    parts = source.Split(char('@'))
    filename = parts[0]
    filename = SysIO.Path.GetFullPath(filename)
    parts = parts[1].Split(char(','))
    tline as int
    int.TryParse(parts[0], tline)
    tcol as int
    int.TryParse(parts[1], tcol)
    code = SysIO.File.ReadAllText(filename)

    target = index.TargetOf(filename, code, tline, tcol)
    if target:
        print target

    return

if cmdLine.HintParse:
    index = ProjectIndex()
    for refe in cmdLine.References:
        index.AddReference(refe)

    sources = array(cmdLine.SourceFiles())
    if len(sources) > 1:
        raise 'Only one source file is supported in hints mode'

    filename = sources[0]
    code = SysIO.File.ReadAllText(filename)

    index.Parse(filename, code)
    return


if cmdLine.HintServer:
    hints(cmdLine)
    return


compiler = newBooJsCompiler(selectPipeline(cmdLine))
configureParams(cmdLine, compiler.Parameters)

# Initial compilation
result = compiler.Run()
showErrorsWarnings(cmdLine, result)

if cmdLine.Watch:
    watch(compiler, cmdLine)
else:
    if len(result.Errors):
        Environment.Exit(2)
