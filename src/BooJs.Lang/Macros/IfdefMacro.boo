namespace BooJs.Lang.Macros

from Boo.Lang.Extensions import IfdefMacro as BooIfdefMacro


class IfdefMacro(BooIfdefMacro):
"""
    Just defined to make it available in a global namespace for BooJs.

    TODO: Send patch to Boo to allow comparison against defined symbol values.

    	ifdef FOO == 'VALUE': ...
    
"""
    pass
