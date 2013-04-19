namespace boojs

import System.IO
import System(Console)
import System.Diagnostics(Stopwatch)

import fastJSON(JSON, JSONParameters)

import boojs.Hints(ProjectIndex, Commands, QueryMessage)


def hints(cmdline as CommandLine):

    index = (ProjectIndex.BooJs() if not cmdline.HintsBoo else ProjectIndex.Boo())
    for refe in cmdline.References:
        index.AddReference(refe)

    # If the output assembly is specified include it as a reference
    if cmdline.OutputDirectory and File.Exists(cmdline.OutputDirectory):
        index.AddReference(cmdline.OutputDirectory)

    json_params = JSONParameters()
    json_params.UseExtensions = false

    if Stopwatch.IsHighResolution:
        print '#Using a Low resolution timer. Reported times may not be accurate.'

    stopwatch = Stopwatch()
    while true:   # Loop indefinitely
        stopwatch.Reset()

        line = gets()
        if line.ToLower() in ('q', 'quit', 'exit'):
            break

        try:
            stopwatch.Start()
            query = JSON.Instance.ToObject[of QueryMessage](line)
            stopwatch.Stop()
        except ex:
            Console.Error.WriteLine('Malformed command')
            continue

        if query.code is null:
            try:
                stopwatch.Start()
                query.code = File.ReadAllText(query.codefile)
                stopwatch.Stop()
            except ex:
                Console.Error.WriteLine('Unable to read code file at ' + query.codefile)
                continue

        method = typeof(Commands).GetMethod(query.command)
        if not method:
            Console.Error.WriteLine('Unknown command')
            continue

        try:
            stopwatch.Start()

            result = method.Invoke(null, (index, query))

            json_params.SerializeNullValues = query.nulls
            print JSON.Instance.ToJSON(result, json_params)

            stopwatch.Stop()
            print '#Command <{0}(extra:{1})> took {2}ms' % (query.command, query.extra, stopwatch.ElapsedMilliseconds)
        except ex:
            Console.Error.WriteLine('Error: ' + ex)
