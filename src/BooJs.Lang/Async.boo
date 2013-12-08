namespace BooJs.Lang.Async

from System import AttributeUsageAttribute, AttributeTargets
from Boo.Lang.Environments import my
from Boo.Lang.Compiler import AbstractAstAttribute, CompilerWarningFactory, CompilerErrorFactory, CompilerContext
from Boo.Lang.Compiler.Ast import *

from BooJs.Lang.Extensions import TransformAttribute


# HACK: We want to reference the _value_ reference inside the generator
#       however when the await macro is expanded that reference does not
#       yet exists. Hence we use the Transform attribute to output the
#       correct reference name and not references to this module.
[Transform( _value_ )]
def _value_() as duck:
    pass
[Transform( _value_ )]
def _valuelist_() as (duck):
    pass


[AttributeUsage(AttributeTargets.Method)]
class AsyncAttribute(AbstractAstAttribute):

    def Apply(node as Node):
        method = node as Method
        method.Body = [|
            return async(): $(method.Body)
        |].ToBlock()


macro await:
    # await foo()  -->  yield foo()
    # await foo(), bar()  -->  yield (foo(), bar())
    # await data = foo()  -->  yield foo() ; data = _value_
    # await data = foo(), bar()  -->  yield (foo(), bar()) ; data = _value_
    # await data, data2 = foo(), bar()  -->  yield (foo(), bar()) ; data, data2 = _value_

    # TODO: Support its use as an expression (meta method?)
    #       foo = await(bar())
    #       data1, data2 = await(foo()), bar()
    #       foo(10, await(bar), false)
    #       # What about the rarely used one's complement?
    #       foo = ~ bar()
    #       foo(10, ~ bar, false)
    # Perhaps is will be better to convert yield to an expression
    # in Boo and then use the upstream changes.

    # TODO: Support specific types for await values

    # Check if the macro is used with async
    has_async = false
    parent = await.GetAncestor[of MethodInvocationExpression]()
    if parent and target = parent.Target as ReferenceExpression:
        has_async = target.Name == 'async'
    unless has_async:
        warning = CompilerWarningFactory.CustomWarning(await, 'await used in a method without the async attribute')
        my(CompilerContext).Warnings.Add(warning)

    decls = ExpressionCollection()
    exprs = ExpressionCollection()
    list = decls
    for arg in await.Arguments:
        if be = arg as BinaryExpression:
            if be.Operator != BinaryOperatorType.Assign:
                error = CompilerErrorFactory.CustomError(be, 'only plain assignments are allowed in await')
                my(CompilerContext).Errors.Add(error)
                return
            decls.Add(be.Left)
            exprs.Add(be.Right)
            list = exprs
        else:
            list.Add(arg)

    # No expressions mean we are not handling an assignment operation
    if len(exprs) == 0:
        exprs, decls = decls, exprs

    if len(exprs) == 0:
        yield [| yield null |]
    if len(exprs) == 1:
        yield [| yield $(exprs[0]) |]
    else:
        yield [| yield $( ArrayLiteralExpression(Items: exprs) ) |]

    if len(decls) == 0:
        pass
    if len(decls) == 1:
        yield [| $(decls[0]) = Async._value_() |]
    else:
        unpack = UnpackStatement()
        for decl as ReferenceExpression in decls:
            unpack.Declarations.Add(Declaration(Name: decl.Name))
        unpack.Expression = [| Async._valuelist_() |]
        yield unpack



interface Thenable:
""" Thenable interface allows to interoperate with other promises/futures
    implementations that follow the Promises/A spec by defining a `then` method.
"""
    def @then(ok as callable, error as callable) as Thenable


interface IPromise(Thenable):
""" Promise interface compatible with the Promises/A+ spec
"""
    def @then(ok as callable) as IPromise
    def catch() as IPromise
    def catch(fn as callable) as IPromise


internal class Promise(IPromise):
    def @then(ok as callable) as IPromise:
        pass
    def @then(ok as callable, error as callable) as Thenable:
        pass
    def catch() as IPromise:
        pass
    def catch(fn as callable) as IPromise:
        pass


class Deferred:

    enum State:
        Unresolved
        Resolved
        Rejected
        Cancelled

    static public onError as callable

    private state as State
    private value as object

    public promise as IPromise

    def constructor():
        pass

    def is_pending():
        pass

    def callbacks(ok as callable, error as callable):
        pass

/*

class Resolver:
    enum State:
        Pending
        Accepted
        Rejected

    private _state = State.Pending
    private _value as object
    protected _accepts = List[of callable]()
    protected _rejects = List[of callable]()

    def resolve(value):
    """ If value is a thenable then we chain into it, otherwise it just
        accepts the value
    """
        if value isa Promise:
            (value as Promise).done(resolve, reject)
        elif value isa Thenable:
            (value as Thenable).@then(resolve, reject)
        else:
            accept(value)

    def accept(value):
    """ Resolves the chain of promises accepting them
    """
        return unless _state == State.Pending
        _state = State.Accepted
        _value = value
        for fn in _accepts:
            enqueue: fn(value)

    def reject(error):
    """ Resolves the chain of promises rejecting them
    """
        return unless _state == State.Pending
        _state = State.Rejected
        _value = error
        for fn in _rejects:
            enqueue: fn(error)

    def add_accept(fn as callable):
        if _state == State.Pending:
            _accepts.push(fn)
        elif _state == State.Accepted:
            enqueue({ fn(_value) })

    def add_reject(fn as callable):
        if _state == State.Pending:
            _rejects.push(fn)
        elif _state == State.Rejected:
            enqueue({ fn(_value) })


class Promise(IPromise):

    static def toPromise(value as object):
        if value isa Thenable:
            return value
        else:
            return Promise() do (resolver):
                resolver.resolve(p)

    static def any(*values as (object)):
        promises = [toPromise(v) for v in values]
        return Promise() do(resolver):
            if not len(promises):
                resolver.reject('No promises passed to any()')
                return

            count = 0
            failures = def (e):
                count++
                if count == len(promises):
                    resolver.reject()

            for p in promises:
                p.done(resolver.resolve, failures)

    static def every(*values as (object)):
        promises = [toPromise(v) for v in values]
        return Promise() do(resolver):
            if not len(promises):
                resolver.reject('No promises passed to every()')
                return

            values = array(len(promises))
            count = 0

            def accumulate(idx, value):
                count++
                values[idx] = value
                if count == len(promises):
                    resolver.resolve(values)

            for idx in range(len(promises)):
                if promises[idx] isa Promise:
                    promises[idx].done({v| accumulate(idx, value)}, resolver.reject)
                else:
                    promises[idx].@then({v| accumulate(idx, v)}, resolver.reject)

    static def some(*values as (object)):
        pass


    private resolver = Resolver()

    def constructor(init as callable(Resolver)):
    """ Create a promise by passing the action to perform to initialize it.
        The function will receive as parameter a Resolver object to mutate
        the state of the Promise.
    """
        try:
            init(resolver) if init
        except ex:
            resolver.reject(ex)

    protected def _wrap(resolver as Resolver, fn as callable):
        return def (value):
            try:
                resolver.resolve(fn(value))
            except ex:
                resolver.reject(ex)

    def @then(accept as callable) as Promise:
    """ Adds a new step in the promises chain
    """
        return @then(accept, null)

    def @then(accept as callable, reject as callable) as Promise:
        return Promise() do (r):
            accept = (_wrap(resolver, accept) if accept else resolver.accept)
            r.add_accept(accept)

            reject = (_wrap(resolver, reject) if reject else resolver.reject)
            r.add_reject(reject)

    def catch(reject as callable) as Promise:
    """ Captures a rejection in the promises chain
    """
        return @then(null, reject)

    def done():
    """ Use this to indicate the end of a promises chain
    """
        done(null, null)

    def done(accept as callable):
        done(accept, null)

    def done(accept as callable, reject as callable):
        resolver.add_accept(accept) if accept
        resolver.add_reject(reject) if reject

*/

def enqueue(fn as callable):
    pass

def async(fn as callable) as Promise:
    pass

def when(*promises as (object)) as Promise:
    pass

def sleep(ms as int) as Promise:
    pass
def sleep(ms as int, fn as callable) as Promise:
    pass
