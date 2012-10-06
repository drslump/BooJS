namespace BooJs.Lang.Extensions

import System

[AttributeUsage(AttributeTargets.Method, Inherited:false, AllowMultiple:false)]
class JsRewriteAttribute(Attribute):
""" Allows to rewrite the annotated member using the given template.

    [JsRewrite('parseInt($2 / $1)')]
    def int_divide(a as int, b as int):
        pass

    int_divide(10, Math.floor(val))
    ---
    parseInt(Math.floor(val) / 10)
"""
    [getter(Value)]
    _value as string

    def constructor(rewrite as string):
        _value = rewrite
