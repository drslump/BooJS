namespace boojs

import System.IO
import System(Console, ConsoleColor, DateTime)
import BooJs.Compiler(CompilerContext)
import BooJs.Compiler.Pipelines(BooJsCompiler)


def watch(compiler as BooJsCompiler, cmdline as CommandLine):

    filenames = []

    def notify(sender, e as FileSystemEventArgs):
        return unless e.FullPath in filenames

        print "{0} Compilation triggered by $(e.FullPath)" % (DateTime.Now.ToString('HH:mm:ss'),)

        old_color = Console.ForegroundColor
        result = compiler.Run()
        for warning in result.Warnings:
            Console.ForegroundColor = ConsoleColor.Yellow
            System.Console.Error.WriteLine( warning )

        for error in result.Errors:
            Console.ForegroundColor = ConsoleColor.Red
            System.Console.Error.WriteLine( error )

        Console.ForegroundColor = old_color

    for inp in compiler.Parameters.Input:
        filenames.Add(Path.GetFullPath(inp.Name))

    for refe as duck in compiler.Parameters.References:
        filenames.Add(refe.Assembly.Location) if refe.Assembly and refe.Assembly.Location

    paths = []
    for fname in filenames:
        if compiler.Parameters.TraceInfo:
            print 'Watching {0}...' % (fname,)
        path = Path.GetDirectoryName(fname)
        if path not in paths:
            paths.Add(path)
            fsw = FileSystemWatcher(path)
            fsw.EnableRaisingEvents = true
            fsw.Changed += notify

    while true:
        System.Threading.Thread.Sleep(50)
