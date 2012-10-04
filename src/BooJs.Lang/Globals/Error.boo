namespace BooJs.Lang.Globals

class Error(Object):

    public message as string

    def constructor():
        pass
    def constructor(msg as string):
        pass

class EvalError(Error):
        pass

class RangeError(Error):
        pass

class ReferenceError(Error):
        pass

class SyntaxError(Error):
        pass

class TypeError(Error):
        pass

class URIError(Error):
    def constructor(msg as string):
        pass

