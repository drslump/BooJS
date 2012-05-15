namespace Boojs.Lang

class global(Boo.Lang.IQuackFu):
""" Special class/type to easily define variables without shadowing them """

    def QuackGet(name as string, params as (object)) as object:
        pass

    def QuackSet(name as string, params as (object), value as object) as object:
        pass

    def QuackInvoke(name as string, args as (object)) as object:
        pass

