namespace BooJs.Compiler

import Boo.Lang.Compiler.Ast

# import BooJs.Compiler.Mozilla.Node as MozNode

class CompilerContext(Boo.Lang.Compiler.CompilerContext):

    # [Property(MozillaUnit)]
    # _mozilla_unit as MozNode

    def constructor(params as CompilerParameters, unit as CompileUnit):
        super(params, unit)
