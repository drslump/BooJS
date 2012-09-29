namespace BooJs.Macros

import Boo.Lang.Compiler
import Boo.Lang.Compiler.Ast

macro print:
    log = [| BooJs.Lang.BuiltinsModule.print() |]
    log.Arguments = print.Arguments
    yield log


macro global:
    for idx as int, arg in enumerate(global.Arguments):
        if not arg isa ReferenceExpression:
            raise System.ArgumentException("global argument $(idx+1) must be an identifier")
        decl = Declaration(Name: arg.ToString(), Type: SimpleTypeReference('Global'))
        yield DeclarationStatement(Declaration: decl)
