namespace Browser

import BooJs.Lang.Extensions


[extern]
static class window:
    interface Storage:

        self[idx as string] as object:
            get
            set

        length as int:
            get

        def getItem(key as string) as object
        def setItem(key as string, data as object)
        def removeItem(key as string)
        def clear()
        def key(idx as int) as string


    public localStorage as Storage

    public requestAnimationFrame as callable


    def setTimeout(func as callable, delay as int) as object:
        pass
    def clearTimeout(id):
        pass

    def setInterval(func as callable, delay as int) as object:
        pass
    def clearInterval(id):
        pass

    [Transform( window.addEventListener($1, $2, false) )]
    def addEventListener(type as string, listener as object):
        pass
    def addEventListener(type as string, listener as object, useCapture as bool):
        pass

    [Transform( window.removeEventListener($1, $2, false) )]
    def removeEventListener(type as string, listener as object):
        pass
    def removeEventListener(type as string, listener as object, useCapture as bool):
        pass

    def alert(msg as string):
        pass
    def prompt(msg as string) as string:
        pass
    def confirm(msg as string) as bool:
        pass

    def escape(str as string) as string:
        pass
    def unescape(str as string) as string:
        pass

