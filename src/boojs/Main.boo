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
