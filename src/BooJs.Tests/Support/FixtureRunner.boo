namespace BooJs.Tests.Support

import NUnit.Framework

import System.IO(Path, Directory, StreamReader)
import System.Reflection(Assembly)
import System.Timers(Timer)

import Boo.Lang.Compiler.IO
from Boo.Lang.Compiler import CompilerError, CompilerWarning
import BooJs.Compiler
import BooJs.Compiler.Pipelines as Pipelines

# The JavaScript interpreter
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
      # comp.Parameters.TraceLevel = System.Diagnostics.TraceLevel.Verbose


      #print 'Setup: ', timer.ElapsedMilliseconds

      expected_diags = []

      # Check if we want to ignore this fixture
      fp = StreamReader(file)
      while (line = fp.ReadLine()) != null:
        if line.IndexOf('#IGNORE') == 0:
          Assert.Ignore(line.Substring(len('#IGNORE')+1))
        elif line.IndexOf('#DUCKY') == 0:
          comp.Parameters.Ducky = true
        elif line.IndexOf('#BCE') == 0 or line.IndexOf('#BCW') == 0:
          expected_diags.Add(line.Substring(1, 7).TrimEnd())
        elif line.IndexOf('#UNSUPPORTED') == 0:
          return

      comp.Parameters.Input.Clear()
      comp.Parameters.Input.Add(FileInput(file))

      # Add the test runner assembly so we can resolve imports for supporting types
      comp.Parameters.References.Add(Assembly.GetExecutingAssembly())

      timer.Restart()

      result = comp.Run()

      #print 'Compilation: ', timer.ElapsedMilliseconds

      if len(expected_diags):
          for warn as CompilerWarning in result.Warnings:
              expected_diags.Remove(warn.Code)
          for err as CompilerError in result.Errors:
              expected_diags.Remove(err.Code)
          if len(expected_diags):
              raise 'Expected ' + join(expected_diags, ', ')
          return

      for warn as CompilerWarning in result.Warnings:
          li = warn.LexicalInfo
          name = System.IO.Path.GetFileName(li.FileName)
          print "$(warn.Code) $(warn.Message) [$name:$(li.Line),$(li.Column)]"

      if len(result.Errors):
          for err as CompilerError in result.Errors:
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
                # print args.Step, args.Context.CompileUnit

            _comp = Pipelines.newBooJsCompiler(pipeline)
            _comp.Parameters.Debug = true
            _comp.Parameters.GenerateInMemory = true

        # Reset the output writer
        _comp.Parameters.OutputWriter = System.IO.StringWriter()
        return _comp

    static def setupInterpreter():
        if not self._engine:
            engine = ScriptEngine()
            # Try to target older browser with ES3 (JS 1.5)
            engine.CompatibilityMode = CompatibilityMode.ECMAScript3
            # Force strict mode
            engine.ForceStrictMode = true

            # TODO: Does this help us somehow to get better error reports?
            #engine.EnableDebugging = true

            # Configure the global environment
            engine.SetGlobalFunction('setTimeout', Window.setTimeout)

            console = ConsoleMock(engine)
            engine.SetGlobalValue('console', console)

            # Load runtime
            engine.ExecuteFile('resources/Boo.js')
            #engine.ExecuteFile('resources/Boo.debug.js')
            engine.ExecuteFile('resources/Boo.Async.js')

            # Patch the runtime to be compatible with Jurassic
            engine.Execute('Boo.AssertionError.prototype.toString = function(){ return this.message; };')

            # Load tests support types
            engine.ExecuteFile('resources/BooJs.Tests.Support.js')

            self._engine = engine

        return self._engine

    static def runTest(code as string, expected as string):

        print '----------------------------------------------[code]-'
        print code.Trim()

        using engine = setupInterpreter():

          console as ConsoleMock = engine.GetGlobalValue('console')
          console.reset()

          try:
            engine.Execute(code)
            Window.waitTimers()

            Assert.AreEqual(expected, console.output())
          except ex:
            Window.clearTimers()
            
            if jsex = ex as Jurassic.JavaScriptException:
                print '---------------------------------------------[error]-'
                print "{0} at {1}@{2}:{3}" % (jsex.Message, jsex.FunctionName, jsex.SourcePath, jsex.LineNumber)

            print '--------------------------------------------[output]-'
            print console.output()
            print '-----------------------------------------------------'

            raise
