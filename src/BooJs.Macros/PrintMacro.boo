namespace BooJs.Macros

import Boo.Lang.Compiler
import Boo.Lang.Compiler.Ast

macro print:
    log = [| BooJs.Lang.BuiltinsModule.print() |]
    log.Arguments = print.Arguments
    yield log


macro global:
    for arg in global.Arguments:
        if not arg isa ReferenceExpression:
            raise System.ArgumentException("global argument must be an identifier")

        decl = Declaration(Name: arg.ToString(), Type: SimpleTypeReference('Global'))
        yield DeclarationStatement(Declaration: decl)
