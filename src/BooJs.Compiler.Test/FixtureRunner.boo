import NUnit.Framework

import System.IO(StreamReader)

import Boo.Lang.Parser
import Boo.Lang.Compiler.Ast
import Boo.Lang.Compiler.IO
import BooJs.Compiler

# The JavaScript interpretter
import Jurassic
import Jurassic.Library

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



class FixtureRunner:

    static _comp as BooJsCompiler
    static _engine as ScriptEngine

    static def run(file as string):

      comp = setupCompiler()
      comp.Parameters.Ducky = false

      # Check if we want to ignore this fixture
      fp = StreamReader(file)
      while (line = fp.ReadLine()) != null:
        if line.IndexOf('#IGNORE') == 0:
          Assert.Ignore(line.Substring(len('#IGNORE')+1))
        elif line.IndexOf('#DUCKY') == 0:
          comp.Parameters.Ducky = true

      comp.Parameters.Input.Clear()
      comp.Parameters.Input.Add(FileInput(file))

      result = comp.Run()
      assert 0 == len(result.Errors), result.Errors.ToString(true) + result.CompileUnit.ToCodeString()

      module = result.CompileUnit.Modules[0]
      expected = module.Documentation or ''

      code = comp.Parameters.OutputWriter.ToString()
      runTest(code, expected)


    static def setupCompiler():
        if not _comp:
            pipeline = Pipelines.ProduceBooJs()
            _comp = newBooJsCompiler(pipeline)
            _comp.Parameters.Debug = true

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
            console = ConsoleMock(self._engine)
            self._engine.SetGlobalValue('console', console)

            # Load runtime
            self._engine.ExecuteFile('/Users/drslump/www/boojs/src/Boo.js')

        return self._engine

    static def runTest(code as string, expected as string):
        print '---------------------------------------------[code]-'
        print code


        # TODO: Check if we can reuse the same engine
        using engine = setupInterpreter():

          console as ConsoleMock = engine.GetGlobalValue('console')
          console.reset()

          # Wrap code is a function to avoid leaking many globals
          #code = "(function(){\n\n" + code + "\n\n}).call(this)\n"

          try:
            engine.Execute(code)
          except e as JavaScriptException:
            assert false, e.Message + "\n----------------------\n" + code
          except e as System.Exception:
            assert false, e.ToString() + "\n---------------------\n" + code
          ensure:
            print '--------------------------------------------[output]-'
            print console.output()
            print '-----------------------------------------------------'

          Assert.AreEqual(expected, console.output())
