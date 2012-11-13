namespace BooJs.Lang.Browser

import BooJs.Lang.Extensions

[extern]
class window:
    static def setTimeout(func as callable, delay as int) as object:
        pass
    static def clearTimeout(id):
        pass

    static def setInterval(func as callable, delay as int) as object:
        pass
    static def clearInterval(id):
        pass

    [Transform( window.addEventListener($1, $2, false) )]
    static def addEventListener(type as string, listener as object):
        pass
    static def addEventListener(type as string, listener as object, useCapture as bool):
        pass

    [Transform( window.removeEventListener($1, $2, false) )]
    static def removeEventListener(type as string, listener as object):
        pass
    static def removeEventListener(type as string, listener as object, useCapture as bool):
        pass

    static def alert(msg as string):
        pass
    static def prompt(msg as string) as string:
        pass
    static def confirm(msg as string) as bool:
        pass

    static def escape(str as string) as string:
        pass
    static def unescape(str as string) as string:
        pass

