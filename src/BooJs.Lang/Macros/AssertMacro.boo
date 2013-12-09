namespace BooJs.Lang.Macros

from Boo.Lang.Compiler import CompilerContext


macro assert:
    return unless CompilerContext.Current.Parameters.Debug

    argc = len(assert.Arguments)
    if argc != 1 and argc != 2:
        raise "assert <condition> [, <message>]"
        
    if 2 == argc:
        cond, msg = assert.Arguments
    else:
        cond, = assert.Arguments
        msg = [| $(cond.ToCodeString()) |]
        
    return [| raise BooJs.Lang.Builtins.AssertionError($msg) unless $cond |]
