namespace BooJs.Lang.Extensions

import System

[AttributeUsage(AttributeTargets.Class | AttributeTargets.Module | AttributeTargets.Enum | AttributeTargets.Struct)]
class ExternAttribute(Attribute):
"""
    Marks a type as an extern, meaning that it merely provides metadata information for
    its members, the actual implementation is provided by the executing runtime.

    [Extern] class XMLHttpRequest:
        pass

    [Extern(Factory:true)]  # Factory means no `new` keyword will be used for the constructors
    class jQuery:
        pass

    [Extern('window.location')] class Location:
        pass
"""

    property Name as string
    property Factory = false

    def constructor():
        pass

    def constructor(name as string):
        Name = name

