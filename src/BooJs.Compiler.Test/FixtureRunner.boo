import NUnit.Framework

import System.IO(StreamReader)

import Boo.Lang.Compiler.IO
import BooJs.Compiler

# The JavaScript interpretter
import Jurassic(ScriptEngine, JavaScriptException, CompatibilityMode)
import Jurassic.Library(ObjectInstance, JSFunctionAttribute)


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
            # Patch the runtime to be compatible with Jurassic
            self._engine.Execute('Boo.AssertionError.prototype.toString = function(){ return this.message; };')

            # Load tests support types
            self._engine.ExecuteFile('/Users/drslump/www/boojs/tests/BooJs.Compiler.Test.Support.js')

        return self._engine

    static def runTest(code as string, expected as string):

        # TODO: Check if we can reuse the same engine
        using engine = setupInterpreter():

          console as ConsoleMock = engine.GetGlobalValue('console')
          console.reset()

          # Wrap code is a function to avoid leaking many globals
          #code = "(function(){\n\n" + code + "\n\n}).call(this)\n"

          try:
            engine.Execute(code)
            Assert.AreEqual(expected, console.output())
          except ex:
            jsex = ex as Jurassic.JavaScriptException
            if jsex:
                jsobj = jsex.ErrorObject as Jurassic.Library.ObjectInstance
                if jsobj and jsobj.HasProperty('boo_filename'):
                  print join(('Exception: "', ex.Message, '" at ',
                          jsobj.GetPropertyValue('boo_filename'), ':',
                          jsobj.GetPropertyValue('boo_line')
                      ), '')

            print '----------------------------------------------[code]-'
            print code.Trim()
            print '--------------------------------------------[output]-'
            print console.output()
            print '-----------------------------------------------------'

            raise

