namespace BooJs.Compiler.TypeSystem

from Boo.Lang.Compiler.TypeSystem import IType
from Boo.Lang.Compiler.TypeSystem.Reflection import ExternalType
from Boo.Lang.Compiler.TypeSystem.Services import DowncastPermissions as BooDowncastPermissions


class DowncastPermissions(BooDowncastPermissions):

    protected virtual def CanBeReachedByInterfaceDowncast(expected as IType, actual as IType) as bool:
        # Boo would always downcast if one of the types is an interface (see BOO-1211).
        # Here we check if the expected type is an interface and if it's then it's probably 
        # safe to downcast the actual value by checking the expected type against the 
        # interfaces the actual value implements.
        if expected.IsInterface and external = actual as ExternalType:
            for iface in external.GetInterfaces():
                return true if iface.IsAssignableFrom(expected)

            # HACK: Map custom IEnumerable interface
            #return expected.FullName == 'System.Collections.Generic.IEnumerable' and actual.FullName == 'BooJs.Lang.Globals.IEnumerable'
            return false

        return true

