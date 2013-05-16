"""
TODO: Check http://jolt.codeplex.com/wikipage?title=Jolt.XmlDocComments

Note: While fastJSON is much faster than JavaScriptSerializer the time spend 
      serializing is not much, thus we can probably avoid having an additional
      dependency.

"""
namespace boojs

import System.IO
import System(Console)
import System.Diagnostics(Stopwatch, Trace, TraceListener, TraceEventCache, TraceEventType)
import System.Web.Script.Serialization(JavaScriptSerializer) from "System.Web.Extensions"

import Boo.Hints(ProjectIndex, Commands)
import Boo.Hints.Messages.Query as QueryMessage


internal class PrefixedTraceListener(TraceListener):
""" Dumps trace messages to the console using a prefix 
"""
    _prefix = '#'

    def constructor(prefix as string):
        _prefix = prefix

    protected def format(msg as string):
        lines = msg.Split(char('\n'))
        return _prefix + join(lines, '\n#')

    override def Write(msg as string):
        WriteLine(msg) 

    override def WriteLine(msg as string):
        # HACK: I can't figure out how to obtain the trace as an object before it's formatted
        parts = msg.Split(char(':'))
        msg = join(parts[2:], ':').TrimStart()
        if parts[0].Contains('Information'):
            Console.Out.WriteLine(format(msg))
        else:
            Console.Error.WriteLine(format(msg))


def hints(cmdline as CommandLine):
    # Setup trace system to use our formatter 
    Trace.AutoFlush = true
    Trace.Listeners.Clear()
    Trace.Listeners.Add(PrefixedTraceListener('#'))

    # TODO: Use a BooJs compiler
    index = ProjectIndex.Boo()
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
        Trace.TraceInformation('Using a Low resolution timer. Reported times may not be accurate')

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
            Console.Out.WriteLine(json.Serialize(result))

            stopwatch.Stop()
            Trace.TraceInformation('Command <{0}(extra:{1})> took {2}ms for {3}' % (query.command, query.extra, stopwatch.ElapsedMilliseconds, query.fname))
        except ex:
            # Print stack trace as debug messages
            lines = ex.ToString().Split(char('\n'))
            Console.Error.WriteLine(join(lines, '\n#'))
