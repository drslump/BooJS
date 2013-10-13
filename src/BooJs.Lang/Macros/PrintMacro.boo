namespace BooJs.Lang.Macros


macro print:
    mie = [| BooJs.Lang.Builtins.print() |]
    mie.Arguments = print.Arguments
    yield mie


