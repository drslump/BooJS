namespace Async

import System
import Boo.Lang.Environments
import Boo.Lang.Compiler
import Boo.Lang.Compiler.Ast

import BooJs.Lang.Extensions


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

    # Check if the macro is used with async
    has_async = false
    parent = await.ParentNode
    while parent:
        if mie = parent as MethodInvocationExpression:
            target = mie.Target as ReferenceExpression
            if target and target.Name == 'async':
                has_async = true
                break

        parent = parent.ParentNode

    if not has_async:
        warning = CompilerWarningFactory.CustomWarning(await, 'await macro is being used in a method without the async attribute')
        my(CompilerContext).Warnings.Add(warning)

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

    # No expressions mean we are not handling an assignment operation
    if len(exprs) == 0:
        exprs, decls = decls, exprs

    if len(exprs) == 1:
        yield [| yield $(exprs[0]) |]
    else:
        yield [| yield $( ArrayLiteralExpression(Items: exprs) ) |]

    if len(decls) == 1:
        yield [| $(decls[0]) = Async.__value() |]
    elif len(decls) > 1:
        unpack = UnpackStatement()
        for decl as ReferenceExpression in decls:
            unpack.Declarations.Add(Declaration(Name: decl.Name))
        unpack.Expression = [| Async.__valuelist() |]
        yield unpack




[AttributeUsage(AttributeTargets.Method)]
class AsyncAttribute(AbstractAstAttribute):

    def Apply(node as Node):
        method = node as Method
        method.Body = [|
            return async(): $(method.Body)
        |].ToBlock()



interface IPromise:
    def @then(okHandler as callable, errorHandler as callable, progressHandler as callable) as IPromise


internal class Promise(IPromise):

    def constructor(defer as Deferred):
        pass

    def done(fn as callable(object)) as Promise:
        pass

    def fail(fn as callable(object)) as Promise:
        pass

    def always(fn as callable(object)) as Promise:
        pass

    [Transform( then($1, $2, $3) )]
    virtual def @then(okHandler as callable, errorHandler as callable, progressHandler as callable) as IPromise:
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

    def @then(okHandler as callable, errorHandler as callable, progressHandler as callable) as IPromise:
        pass

    def cancel():
        pass


def enqueue(fn as callable):
    pass

def async(fn as callable) as IPromise:
    pass

def when(*promises as (object)) as IPromise:
    pass

def sleep(ms as int) as IPromise:
    pass
