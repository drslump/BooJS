namespace BooJs.Lang.Async

import BooJs.Lang.Extensions

import System
import Boo.Lang.Compiler
import Boo.Lang.Compiler.Ast


[Transform( __value )]
def __value() as object:
    pass

macro await:
    be = await.Arguments[0] as BinaryExpression
    if be:
        yield [| yield $(be.Right) |]
        yield [| $(be.Left) = BooJs.Lang.Async.__value() |]


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

def sleep(ms as int) as IPromise:
    pass


/*

callable AsyncWrapper(*args) as IPromise

def async(fn as callable) as AsyncWrapper:
    return def(*args):
        # TODO: This won't work, we have to wait until the wrapped generator exists to
        #       fulfill the async deferred
        defer = Deferred()

        gen = fn(*args)
        try:
             result = generator.next()
             unless result isa IPromise:
                 raise 'A non promise value was yielded back'

             result.@then({v| generator.send(v)}, {e| generator.throw(e)})
         except as StopIteration:
             pass
         except e:
             defer.errback(e)
         ensure:
             generator.close()

         return defer

def join(*args as (IPromiseA)) as IPromiseA:
    pass

def spawn(fn as callable):
    pass

def sleep(delay, compensate):
    pass
*/