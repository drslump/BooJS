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
        Console.Error.WriteLine('# Using a High Resolution timer')

    while true:   # Loop indefinitely
        line = gets()
        if line.ToLower() in ('q', 'quit', 'exit'):
            break

        try:
            watch_parse = Stopwatch.StartNew()
            query = JSON.Instance.ToObject[of QueryMessage](line)
            watch_parse.Stop()
        except ex:
            Console.Error.WriteLine('Malformed command')
            continue

        try:
            if query.code is null:
                query.code = File.ReadAllText(query.codefile)
        except ex:
            Console.Error.WriteLine('Unable to read code file at ' + query.codefile)
            continue

        method = typeof(Commands).GetMethod(query.command)
        if not method:
            Console.Error.WriteLine('Unknown command')
            continue

        try:
            watch_process = Stopwatch.StartNew()
            result = method.Invoke(null, (index, query))
            watch_process.Stop()

            watch_serialize = Stopwatch.StartNew()
            json_params.SerializeNullValues = query.nulls == true
            print JSON.Instance.ToJSON(result, json_params)
            watch_serialize.Stop()

            Console.Error.WriteLine('# Command: {0} -- Parse: {1} - Process: {2} - Serialize: {3}' % (
                query.command,
                watch_parse.ElapsedMilliseconds, watch_process.ElapsedMilliseconds, watch_serialize.ElapsedMilliseconds
            ))
        except ex:
            Console.Error.WriteLine('Error: ' + ex)
