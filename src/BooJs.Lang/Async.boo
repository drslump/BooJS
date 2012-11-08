namespace BooJs.Lang.Async

import BooJs.Lang.Extensions

import System
import Boo.Lang.Compiler
import Boo.Lang.Compiler.Ast


[Transform( __value )]
def __value() as object:
    pass
[Transform( __value )]
def __valuelist() as (object):
    pass


macro await:
    # await foo()
    # await foo(), bar()  <==>  (foo(), bar())
    # await data = foo()
    # await data = foo(), bar()
    # await data, data2 = foo(), bar()

    # TODO: Support type definitions

    decls = ExpressionCollection()
    exprs = ExpressionCollection()
    list = decls
    for arg in await.Arguments:
        if be = arg as BinaryExpression:
            if be.Operator != BinaryOperatorType.Assign:
                raise 'Invalid operator, only simple assigns are allowed'
            decls.Add(be.Left)
            exprs.Add(be.Right)
            list = exprs
            continue

        list.Add(arg)

    if len(exprs) == 1:
        yield [| yield $(exprs[0]) |]
    else:
        yield [| yield $( ArrayLiteralExpression(Items: exprs) ) |]

    if len(decls) == 1:
        yield [| $(decls[0]) = BooJs.Lang.Async.__value() |]
    elif len(decls) > 1:
        unpack = UnpackStatement()
        for decl as ReferenceExpression in decls:
            unpack.Declarations.Add(Declaration(Name: decl.Name))
        unpack.Expression = [| BooJs.Lang.Async.__valuelist() |]
        yield unpack




[AttributeUsage(AttributeTargets.Method)]
class AsyncAttribute(AbstractAstAttribute):

    def Apply(node as Node):
        method = node as Method
        method.Body = [|
            return async(): $(method.Body)
        |].ToBlock()



interface IPromise:
    def _then(okHandler as callable, errorHandler as callable, progressHandler as callable) as IPromise


class Promise(IPromise):

    def constructor(defer as Deferred):
        pass

    def done(fn as callable(object)) as Promise:
        pass

    def fail(fn as callable(object)) as Promise:
        pass

    def always(fn as callable(object)) as Promise:
        pass

    [Transform( then($1, $2, $3) )]
    virtual def _then(okHandler as callable, errorHandler as callable, progressHandler as callable) as IPromise:
        pass

    virtual def cancel():
        pass


enum DeferredState:
    Unresolved
    Resolved
    Rejected
    Cancelled

class Deferred:

    public promise = Promise(self)


    def constructor():
        pass

    def constructor(cancel as callable):
        pass

    def getState() as DeferredState:
        pass

    def resolve(value):
        pass

    def reject(error):
        pass

    def progress(update):
        pass

    [Transform( then($1, $2, $3) )]
    def _then(okHandler as callable, errorHandler as callable, progressHandler as callable) as IPromise:
        pass

    def cancel():
        pass




def async(fn as callable) as IPromise:
    pass

def when(*promises as (IPromise)) as IPromise:
    pass

def sleep(ms as int) as IPromise:
    pass
