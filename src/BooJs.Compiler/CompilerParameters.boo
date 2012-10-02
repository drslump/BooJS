namespace BooJs.Compiler

import Boo.Lang.Compiler.TypeSystem.Reflection
import Boo.Lang.Compiler.CompilerParameters as BooCompilerParameters

class CompilerParameters(BooCompilerParameters):

    def constructor(provider as IReflectionTypeSystemProvider):
        super(provider)
