namespace BooJs.Lang.Globals


static class JSON(Object):

    def parse(text as string) as object:
        pass
    def parse(text as string, reviver_opt as callable(object, object) as object) as object:
        pass
        
    def stringify(value as object) as string:
        pass
    def stringify(value as object, replaceer as callable(string, object) as object) as string:
        pass
    def stringify(value as object, replacer as object*) as string:
        pass
    def stringify(value as object, replacer as callable(string, object) as object, space as object) as string:
        pass
    def stringify(value as object, replacer as object*, space as object) as string:
        pass

