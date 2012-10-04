namespace BooJs.Lang.Globals

class Function(Object, ICallable):

    # ICallable interface
    def Call(params as (object)) as object:
        pass

    public length as uint

    def apply(this as object, args as (object)) as object:
        pass
    def call(this as object, *args as (object)) as object:
        pass


    # ECMAScript 5th Edition

    def bind(this as object, *args as (object)) as Function:
        pass
