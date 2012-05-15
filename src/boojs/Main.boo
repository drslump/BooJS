namespace boojs

import System
import System.Reflection
import System.Diagnostics
import System.IO as SysIO
import Boo.Lang.Compiler
import Boo.Lang.Compiler.IO
import Boojs.Compilation from Boojs.Compilation
import Boojs.Compilation.TypeSystem from Boojs.Compilation

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
    return BoojsPipelines.ProduceJs()
    
def configureParams(cmdLine as CommandLine, params as CompilerParameters):
    for fname in cmdLine.SourceFiles():
        if cmdLine.Verbose: print fname
        params.Input.Add(FileInput(fname))

    params.OutputAssembly = getOutputDirectory(cmdLine)
    if cmdLine.DebugCompiler:
        params.TraceLevel = System.Diagnostics.TraceLevel.Verbose
        Trace.Listeners.Add(TextWriterTraceListener(System.Console.Error))

def showErrorsWarnings(cmdLine as CommandLine, result as CompilerContext):
    for error in result.Errors:
        print error.ToString(cmdLine.Verbose)
    for warning in result.Warnings:
        print warning
    
def getOutputDirectory(cmdLine as CommandLine):
    return cmdLine.OutputDirectory

[extension]
def RemoveStart(value as string, start as string):
    return value unless value.StartsWith(start)
    return value[start.Length:]



cmdLine = parseCommandLine(argv)
if cmdLine is null: return

compiler = newBoojsCompiler(selectPipeline(cmdLine))
configureParams(cmdLine, compiler.Parameters)

result = compiler.Run()

showErrorsWarnings(cmdLine, result)
