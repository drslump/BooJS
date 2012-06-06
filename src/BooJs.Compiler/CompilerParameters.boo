namespace BooJs.Compiler

import Boo.Lang.Compiler.TypeSystem.Reflection

class CompilerParameters(Boo.Lang.Compiler.CompilerParameters):

    def constructor(provider as IReflectionTypeSystemProvider):
        super(provider)
