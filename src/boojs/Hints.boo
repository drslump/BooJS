"""
TODO: Check http://jolt.codeplex.com/wikipage?title=Jolt.XmlDocComments

Note: While fastJSON is much faster that JavaScriptSerializer the time spend 
      serializing is not much, thus for the time being is preferred to avoid
      including an additional dependency.

TODO: Use System.Diagnostics.Trace with a custom formatter to prefix with '#'
"""
namespace boojs

import System.IO
import System(Console)
import System.Diagnostics(Stopwatch)
import System.Web.Script.Serialization

import boojs.Hints(ProjectIndex, Commands)
import boojs.Hints.Messages.Query as QueryMessage


def hints(cmdline as CommandLine):

    index = (ProjectIndex.BooJs() if not cmdline.HintsBoo else ProjectIndex.Boo())
    for refe in cmdline.References:
        index.AddReference(refe)

    # If the output assembly is specified include it as a reference
    if cmdline.OutputDirectory and File.Exists(cmdline.OutputDirectory):
        index.AddReference(cmdline.OutputDirectory)

    # Complete index setup
    index.Init()

    # Initialize the commands
    commands = Commands(index)

    # Initialize the json serializer
    json = JavaScriptSerializer()


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
            query = json.Deserialize[of QueryMessage](line)
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

            result = method.Invoke(commands, (query,))
            print json.Serialize(result)

            stopwatch.Stop()
            print '#Command <{0}(extra:{1})> took {2}ms for {3}' % (query.command, query.extra, stopwatch.ElapsedMilliseconds, query.fname)
        except ex:
            Console.Error.WriteLine(join(ex.ToString().Split(char('\n')), '\n#'))
