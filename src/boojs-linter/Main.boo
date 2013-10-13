namespace boojs

import BooJs.Compiler
import BooJs.Compiler.Pipelines
import Boo.Lang.Compiler.IO(FileInput)


try:
    cmdLine = CommandLine(argv)
    if not cmdLine.IsValid or cmdLine.DoHelp:
        cmdLine.PrintOptions()
        return
except x:
    print "BCE000: ", x.Message
    return


compiler = newBooJsCompiler(LintPipeline())

for fname in cmdLine.SourceFiles():
    compiler.Parameters.Input.Add(FileInput(fname))

result = compiler.Run()

for warning in result.Warnings:
    System.Console.Error.WriteLine( warning )
for error in result.Errors:
    System.Console.Error.WriteLine( error.ToString(cmdLine.Verbose) )
