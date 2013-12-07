namespace boojs

from System import Console, Environment, IO as SysIO
from System.Reflection import Assembly
from System.Diagnostics import Trace, TraceLevel, TextWriterTraceListener
from Boo.Lang.Compiler import CompilerContext as BooCompilerContext
from Boo.Lang.Compiler.IO import FileInput
from BooJs.Compiler.Pipelines import SaveJs, PrintBoo, PrintJs, PrintAst, newBooJsCompiler
from BooJs.Compiler import CompilerParameters as JsCompilerParameters, CompilerContext as JsCompilerContext


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
        print "BCE0000: ", x.Message
        return null

def selectPipeline(cmdLine as CommandLine):
    pl = (cmdLine.Pipeline.ToLower() if cmdLine.Pipeline else 'save')
    if pl == 'boo':
        return PrintBoo()
    elif pl == 'js':
        return PrintJs()
    elif pl == 'ast':
        return PrintAst()
    elif pl == 'save':
        return SaveJs()

    print 'BCE0000: Unknown pipeline name'
    Environment.Exit(1)
    

def configureParams(cmdLine as CommandLine, params as JsCompilerParameters):
    params.Debug = cmdLine.Debug
    params.OutputAssembly = getOutputDirectory(cmdLine)
    params.Ducky = cmdLine.Ducky
    params.EmbedTypes = cmdLine.EmbedTypes
    params.SourceMap = cmdLine.SourceMap
    params.SourceMapRoot = cmdLine.SourceMapRoot

    if cmdLine.Verbose:
        params.TraceLevel = TraceLevel.Verbose
        Trace.Listeners.Add(TextWriterTraceListener(System.Console.Error))

    for refe in cmdLine.References:
        params.LoadAssembly(refe)

    for fname in cmdLine.SourceFiles():
        params.Input.Add(FileInput(fname))

def showErrorsWarnings(cmdLine as CommandLine, result as BooCompilerContext):
    for warning in result.Warnings:
        Console.Error.WriteLine( warning )
    for error in result.Errors:
        Console.Error.WriteLine( error.ToString(cmdLine.Verbose) )

def getOutputDirectory(cmdLine as CommandLine):
    return cmdLine.OutputDirectory




cmdLine = parseCommandLine(argv)
if cmdLine is null: return


if cmdLine.HintsServer:
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
