namespace BooJs.Lang.Macros

macro print:
    log = [| BooJs.Lang.Builtins.print() |]
    log.Arguments = print.Arguments
    yield log


