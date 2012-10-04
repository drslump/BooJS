namespace BooJs.Lang.Globals

class JSON(Object):

    # TODO: Overload optionals
    static def parse(text as string, reviver_opt as callable(object, object) as object) as object:
        pass
    static def stringify(value as object) as string:
        pass
    static def stringify(value as object, replaceer as callable(string, object) as object) as string:
        pass
    static def stringify(value as object, replacer as object*) as string:
        pass
    static def stringify(value as object, replacer as callable(string, object) as object, space as object) as string:
        pass
    static def stringify(value as object, replacer as object*, space as object) as string:
        pass

