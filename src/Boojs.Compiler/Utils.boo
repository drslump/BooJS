namespace Boojs.Compiler

import Boo.Lang.Compiler.Ast
import Boo.Lang.Compiler.TypeSystem

def boojsCompile(unit as CompileUnit):
    compiler = newBoojsCompiler()
    result = compiler.Run(unit)
    assert 0 == len(result.Errors), result.Errors.ToString(true) + unit.ToCodeString()

def log(message as string):
    using f = System.IO.File.AppendText("/tmp/boojs.txt"):
        f.WriteLine(message)
