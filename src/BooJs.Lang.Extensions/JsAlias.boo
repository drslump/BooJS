namespace BooJs.Lang.Extensions

import System

[AttributeUsage(AttributeTargets.Class | AttributeTargets.Method | AttributeTargets.Field, Inherited:false, AllowMultiple:false)]
class JsAliasAttribute(System.Attribute):
""" Allows to manually alias the annotated member to some custom string

    class Browser:
        [JsName('window.location.fragment')]
        static public fgmt as string

    Browser.fgmt = 'foo'
    ---
    window.location.fragment = 'foo'

    TODO: Use dots to signal relative rewriting ( for 'x.y.z': .foo -> x.y.foo, ..obj.foo -> x.obj.foo)
"""
    [getter(Value)]
    _value as string

    def constructor(name as string):
        _value = name
