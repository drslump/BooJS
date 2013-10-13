namespace BooJs.Tests.Support

import NUnit.Framework

import System.IO(Path, Directory, StreamReader)
import System.Reflection(Assembly)
import System.Timers(Timer)

import Boo.Lang.Compiler.IO
import BooJs.Compiler
import BooJs.Compiler.Pipelines as Pipelines

# The JavaScript interpretter
import Jurassic(ScriptEngine, JavaScriptException, CompatibilityMode)
import Jurassic.Library(ObjectInstance, FunctionInstance, JSFunctionAttribute)


class ConsoleMock(ObjectInstance):
    _output = []

    def constructor(engine as ScriptEngine):
        super(engine)
        PopulateFunctions()

    [JSFunction(Name:'log')]
    def log(*msg as (object)):
        _output.Add(join(msg, ' '))

    def output():
        return _output.Join("\n")

    def reset():
        _output.Clear()

static class Window:
    timers = Boo.Lang.List[of Timer]()

    def hasTimers():
        return len(timers) > 0

    def clearTimers():
        for timer in timers:
            timer.Stop()
        timers.Clear()

    def waitTimers():
        while hasTimers():
            System.Threading.Thread.Sleep(200)

    [JSFunction(Name:'setTimeout')]
    def setTimeout(callback as FunctionInstance, millisec as int) as int:
        timer = Timer(System.Math.Max(millisec, 1))
        timer.AutoReset = false
        timer.Enabled = true
        timer.Elapsed += do:
            try:
                callback.Call(callback)
            ensure:
                timer.Stop()
                timers.Remove(timer)

        timer.Start()
        timers.Add(timer)
        return len(timers)


class FixtureRunner:

    static _comp as Pipelines.BooJsCompiler
    static _engine as ScriptEngine

    static _tests_path as string

    static def fixture_path(fname):
      if not _tests_path:
        # Find the path where the assembly resides
        path = Assembly.GetExecutingAssembly().CodeBase

        # Look for the tests directory in once of its parent paths
        while path = Path.GetFullPath(Path.Combine(path, '..')):
          if Directory.Exists(Path.Combine(path, 'tests')):
            _tests_path = path
            break
          elif path == Path.GetPathRoot(path):
            raise 'Unable to find tests directory'

      return Path.Combine(_tests_path, fname)

    static def run(file as string):
      file = fixture_path(file)

      timer = System.Diagnostics.Stopwatch()

      comp = setupCompiler()
      comp.Parameters.Ducky = false
      comp.Parameters.Strict = false

      # Enable compiler debug messages
      #comp.Parameters.TraceLevel = System.Diagnostics.TraceLevel.Verbose


      #print 'Setup: ', timer.ElapsedMilliseconds

      # Check if we want to ignore this fixture
      fp = StreamReader(file)
      while (line = fp.ReadLine()) != null:
        if line.IndexOf('#IGNORE') == 0:
          Assert.Ignore(line.Substring(len('#IGNORE')+1))
        elif line.IndexOf('#DUCKY') == 0:
          comp.Parameters.Ducky = true

      comp.Parameters.Input.Clear()
      comp.Parameters.Input.Add(FileInput(file))

      # Add the test runner assembly so we can resolve imports for supporting types
      comp.Parameters.References.Add(Assembly.GetExecutingAssembly())

      timer.Restart()

      result = comp.Run()

      #print 'Compilation: ', timer.ElapsedMilliseconds

      if len(result.Warnings):
        for warn as Boo.Lang.Compiler.CompilerWarning in result.Warnings:
            li = warn.LexicalInfo
            name = System.IO.Path.GetFileName(li.FileName)
            print "$(warn.Code) $(warn.Message) [$name:$(li.Line),$(li.Column)]"

      if len(result.Errors):
        for err as Boo.Lang.Compiler.CompilerError in result.Errors:
            li = err.LexicalInfo
            name = System.IO.Path.GetFileName(li.FileName)
            print "$(err.Code): $(err.Message) [$name:$(li.Line),$(li.Column)]"
        print '-----------------------------------------------------'
        print result.CompileUnit.ToCodeString()
        raise result.Errors[0]


      module = result.CompileUnit.Modules[0]
      expected = module.Documentation or ''

      code = comp.Parameters.OutputWriter.ToString()
      runTest(code, expected)


    static def setupCompiler():
        if not _comp:
            pipeline = Pipelines.PrintJs()
            #pipeline = Pipelines.PrintAst()
            #pipeline = Pipelines.PrintBoo()

            timer = System.Diagnostics.Stopwatch()
            pipeline.BeforeStep += def(pipeline, args):
                //print '-------------------------------------------'
                //print 'Step:', args.Step
                //print args.Context.CompileUnit
                timer.Restart()

            pipeline.AfterStep += def(pipeline, args):
                if timer.ElapsedMilliseconds > 100:
                    print 'Slow Step {0}: {1}ms' % (args.Step.GetType().Name, timer.ElapsedMilliseconds)

            _comp = Pipelines.newBooJsCompiler(pipeline)
            _comp.Parameters.Debug = true
            _comp.Parameters.GenerateInMemory = true

        # Reset the output writer
        _comp.Parameters.OutputWriter = System.IO.StringWriter()
        return _comp

    static def setupInterpreter():
        if not self._engine:
            self._engine = ScriptEngine()
            # Try to target older browser with ES3 (JS 1.5)
            self._engine.CompatibilityMode = CompatibilityMode.ECMAScript3
            # Force strict mode
            self._engine.ForceStrictMode = true

            # TODO: Does this help us somehow to get better error reports?
            #engine.EnableDebugging = true

            # Configure the global environment
            self._engine.SetGlobalFunction('setTimeout', Window.setTimeout)

            console = ConsoleMock(self._engine)
            self._engine.SetGlobalValue('console', console)

            # Load runtime
            stream = typeof(FixtureRunner).Assembly.GetManifestResourceStream('Boo.js')
            reader = System.IO.StreamReader(stream)
            self._engine.Execute(reader.ReadToEnd())

            # Patch the runtime to be compatible with Jurassic
            self._engine.Execute('Boo.AssertionError.prototype.toString = function(){ return this.message; };')

            # Load tests support types
            stream = typeof(FixtureRunner).Assembly.GetManifestResourceStream('BooJs.Tests.Support.js')
            reader = System.IO.StreamReader(stream)
            self._engine.Execute(reader.ReadToEnd())

            self._engine.ExecuteFile('/Users/drslump/www/boojs/src/Boo.Async.js')

        return self._engine

    static def runTest(code as string, expected as string):

        print '----------------------------------------------[code]-'
        print code.Trim()

        # TODO: Check if we can reuse the same engine
        using engine = setupInterpreter():

          console as ConsoleMock = engine.GetGlobalValue('console')
          console.reset()

          try:
            engine.Execute(code)
            Window.waitTimers()
            Assert.AreEqual(expected, console.output())
          except ex:
            Window.clearTimers()

            jsex = ex as Jurassic.JavaScriptException
            if jsex:
                jsobj = jsex.ErrorObject as Jurassic.Library.ObjectInstance
                if jsobj and jsobj.HasProperty('boo_filename'):
                  print join(('Exception: "', ex.Message, '" at ',
                          jsobj.GetPropertyValue('boo_filename'), ':',
                          jsobj.GetPropertyValue('boo_line')
                      ), '')

            print '--------------------------------------------[output]-'
            print console.output()
            print '-----------------------------------------------------'

            raise

