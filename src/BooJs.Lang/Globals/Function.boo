namespace BooJs.Lang.Globals

class Function(Object, ICallable):

    # ICallable interface
    def Call(params as (object)) as object:
        pass

    # Number of arguments
    public length as uint

    # See http://www.alertdebugging.com/2009/04/29/building-a-better-javascript-profiler-with-webkit/
    public displayName as string

    def apply(this as object, args as (object)) as object:
        pass
    def call(this as object, *args as (object)) as object:
        pass


    # ECMAScript 5th Edition

    def bind(this as object, *args as (object)) as Function:
        pass
