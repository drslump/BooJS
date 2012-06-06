import NUnit.Framework

import Boo.Lang.Parser
import Boo.Lang.Compiler.Ast
import BooJs.Compiler

import Jint


class ConsoleMock:
  _output = []

  def log(itm as string):
     _output.Add(itm)
  
  def log(itm as bool):
     # Jint prints bool values as True/False instead of true/false
     log( ('true' if itm else 'false') )

  def output():
     return _output.Join("\n")



class FixtureRunner:

    static def run(file as string):
      unit = BooParser.ParseFile(file)
      main = unit.Modules[0]
      Assert.IsNotNull(main.Documentation != null,
          "Expecting documentation for '${file}'")

      code = compile(unit)
      runTest(code, main.Documentation)

    static def compile(unit as CompileUnit):
    
      writer = System.IO.StringWriter()

      pipeline = Pipelines.ProduceBooJs()
      compiler = newBooJsCompiler(pipeline)
      compiler.Parameters.Debug = true
      compiler.Parameters.OutputWriter = writer

      result = compiler.Run(unit)
      assert 0 == len(result.Errors), result.Errors.ToString(true) + unit.ToCodeString()
      
      return writer.ToString()

    static def runTest(code as string, expected as string):
        console = ConsoleMock()
        ctx = _init_jint()
        ctx.SetParameter('console', console)
 
        print '---------------------------------------------[code]-'
        print code
        
        try:
          program = ctx.Compile(code, true)
          ctx.Run(program)
        except e as JintException:
          assert false, e.ToString() + code
        except e as System.Exception:
          assert false, e.ToString() + code
          
        print '--------------------------------------------[output]-'
        print console.output()
        print '-----------------------------------------------------'
 
        Assert.AreEqual(expected, console.output())
 
    protected static def _init_jint():
        # Saving/Restoring state in Jint is broken :(
        ctx = JintEngine()
        ctx.EnableSecurity()
        return ctx
