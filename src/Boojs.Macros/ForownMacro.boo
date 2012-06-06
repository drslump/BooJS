namespace Boojs.Macros

import Boo.Lang.Compiler
import Boo.Lang.Compiler.Ast

# TODO: It's broken right now and I no longer see this as a good
#       pattern. These should be resolved with the runtime .each method
#
#       for v,k in iterator:
#         if iterator.hasOwnProperty(k):
#
#       Boo.each(iterator, function(v,k){
#           if (iterator.hasOwnProperty(k)){
#

macro forown:
    if not len(forown.Arguments):
        raise 'Usage: forown <decl> in <iterator>: <block>'

    inexpr as BinaryExpression = forown.Arguments[0]
    if not inexpr isa BinaryExpression or \
       inexpr.Operator != BinaryOperatorType.Member:
        raise 'Usage: forown <decl> in <iterator>: <block>'

    iter = inexpr.Right

    # TODO: Use key variable is given

    decls = DeclarationCollection()
    decls.Add(Declaration(Name:inexpr.Left.ToString()))
    decls.Add(Declaration(Name:'__key'))

    if_block = [|
        if ($(inexpr.Right) as duck).hasOwnProperty(__key):
            $(forown.Block)
    |]

    for_st = ForStatement(
        Declarations: decls,
        Iterator: inexpr.Right
    )
    for_st.Block.Statements.Insert(0, if_block)

    print for_st

    yield for_st

